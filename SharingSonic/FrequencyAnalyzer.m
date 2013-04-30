//
//  FrequencyAnalyzer.m
//  InputTest
//
//  Created by PowerQian on 11/20/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "FrequencyAnalyzer.h"
#import "NoteDictionary.h"
#import "BasicParameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <signal.h>
#include "libfft.h"

/* -- some basic parameters -- */
#define SAMPLE_RATE 44100
#define FFT_SIZE 256
#define FFT_EXP_SIZE 8
#define NUM_SECONDS 20

/* -- functions declared and used here -- */
void buildHammingWindow( float *window, int size );
void buildHanWindow( float *window, int size );
void applyWindow( float *window, float *data, int size );
//a must be of length 2, and b must be of length 3
void computeSecondOrderLowPassParameters( float srate, float f, float *a, float *b );
//mem must be of length 4.
float processSecondOrderFilter( float x, float *mem, float *a, float *b );
void signalHandler( int signum ) ;

static bool running = true;


@implementation FrequencyAnalyzer

#define MAX_ERROR 100
- (NSString *)findCharacterForFreq:(float)freq
{
    NSString *freqChar;

    NSDictionary *noteDic = [[NoteDictionary defaultDictionary] noteDictionaryForHash];
    NSEnumerator *keyEnumerator = [noteDic keyEnumerator];
    float minDiff = MAXFLOAT;
    
    NSString *key;
    while ((key = [keyEnumerator nextObject])) {
        // iterate all the frequency and find the frequency with the minimum difference
        // the output of fft would not be exactly the same frequency,
        // so we need a threshold:MAX_ERROR
        float currentDiff = ABS(freq - [[noteDic objectForKey:key] floatValue]);
        if (currentDiff < minDiff && currentDiff < MAX_ERROR) {
            minDiff = currentDiff;
            freqChar = key;
        }
    }
    
    return freqChar;
}



- (void)startFrequencyAnalyzeWithSamples:(Float32 *)samples
{
//    for (int i = 0; i < SINGLE_BUFFER_SAMPLE_COUNT; i++) {
//        printf("%f ",samples[i]);
//    }
    dispatch_queue_t fft = dispatch_queue_create("FFT", NULL);
    dispatch_async(fft, ^{
        float freq = 0;
        freq = [self _fftFunctionToSamples:samples];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate analyzeDidFinishWithResultFrequency:freq];
        });
    });
}


//Singleton using GCD
+ (FrequencyAnalyzer *) defaultAnalyzer
{
    static FrequencyAnalyzer *defaultFrequencyAnalyzer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultFrequencyAnalyzer = [[self alloc] init];
    });
    return defaultFrequencyAnalyzer;
}
//Singleton Ended

//******************************************************************************************
//********The following code are all about frequency analyze detail and are all in C********
//********They were found in the Internet. No need to read in detail. In general, it********
//********receive a sample array, return a frequency. That's it                     ********
//******************************************************************************************


//***********FFT used to analyze frequency***********
- (float)_fftFunctionToSamples:(Float32 *)samples
{
    float a[2], b[3], mem1[4], mem2[4];
    float data[FFT_SIZE];
    float datai[FFT_SIZE];
    float window[FFT_SIZE];
//    float freqTable[FFT_SIZE];
    //    char * noteNameTable[FFT_SIZE];
    //    float notePitchTable[FFT_SIZE];
    void * fft = NULL;
    struct sigaction action;
    
    //data initialize
    for (int i = 0; i < FFT_SIZE; i++) {
        data[i] = samples[i];
    }
    
    // add signal listen so we know when to exit:
    action.sa_handler = signalHandler;
    sigemptyset (&action.sa_mask);
    action.sa_flags = 0;
    
    sigaction (SIGINT, &action, NULL);
    sigaction (SIGHUP, &action, NULL);
    sigaction (SIGTERM, &action, NULL);
    
    
    buildHanWindow( window, FFT_SIZE );
    fft = initfft( FFT_EXP_SIZE );
    computeSecondOrderLowPassParameters( SAMPLE_RATE, 330, a, b );
    mem1[0] = 0; mem1[1] = 0; mem1[2] = 0; mem1[3] = 0;
    mem2[0] = 0; mem2[1] = 0; mem2[2] = 0; mem2[3] = 0;
//    //freq/note tables
//    for( int i=0; i<FFT_SIZE; ++i ) {
//        freqTable[i] = ( SAMPLE_RATE * i ) / (float) ( FFT_SIZE );
//    }
    
    applyWindow( window, data, FFT_SIZE );
    
    // do the fft
    for( int j=0; j<FFT_SIZE; ++j )
        datai[j] = 0;
    applyfft( fft, data, datai, false );
    
    //find the peak
    float maxVal = -1;
    int maxIndex = -1;
    for( int j=0; j<FFT_SIZE/2; ++j ) {
        float v = data[j] * data[j] + datai[j] * datai[j] ;
        if( v > maxVal ) {
            maxVal = v;
            maxIndex = j;
        }
    }
    float freq = maxIndex * SAMPLE_RATE / FFT_SIZE;
    
    // Fix the unbounded memory growth.
    destroyfft(fft);
    return freq;
}

//***********C Function used in startFrequencyAnalyzeWithSamples:***********
void buildHammingWindow( float *window, int size )
{
    for( int i=0; i<size; ++i )
        window[i] = .54 - .46 * cos( 2 * M_PI * i / (float) size );
}
void buildHanWindow( float *window, int size )
{
    for( int i=0; i<size; ++i )
        window[i] = .5 * ( 1 - cos( 2 * M_PI * i / (size-1.0) ) );
}
void applyWindow( float *window, float *data, int size )
{
    for( int i=0; i<size; ++i )
        data[i] *= window[i] ;
}
void computeSecondOrderLowPassParameters( float srate, float f, float *a, float *b )
{
    float a0;
    float w0 = 2 * M_PI * f/srate;
    float cosw0 = cos(w0);
    float sinw0 = sin(w0);
    //float alpha = sinw0/2;
    float alpha = sinw0/2 * sqrt(2);
    
    a0   = 1 + alpha;
    a[0] = (-2*cosw0) / a0;
    a[1] = (1 - alpha) / a0;
    b[0] = ((1-cosw0)/2) / a0;
    b[1] = ( 1-cosw0) / a0;
    b[2] = b[0];
}
float processSecondOrderFilter( float x, float *mem, float *a, float *b )
{
    float ret = b[0] * x + b[1] * mem[0] + b[2] * mem[1]
    - a[0] * mem[2] - a[1] * mem[3] ;
    
    mem[1] = mem[0];
    mem[0] = x;
    mem[3] = mem[2];
    mem[2] = ret;
    
    return ret;
}
void signalHandler( int signum ) { running = false; }
//***********C Function Ended.***********


@end
