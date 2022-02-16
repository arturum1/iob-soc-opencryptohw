#include "stdlib.h"
#include <stdio.h>
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "printf.h"

#include "iob_timer.h"

#ifdef PROFILE
#include "profile.h"
#endif

#include "crypto/sha2.h"

#include "test_vectors.h"

#define HASH_SIZE (256/8)

char HexTable[16] = "0123456789abcdef";

char* GetHexadecimal(const char* text, int str_size){
  static char buffer[2048+1];
  int i;

  for(i = 0; i< str_size; i++){
    if(i * 2 > 2048){
      printf("\n\n<GetHexadecimal> Maximum size reached\n\n");
      buffer[i*2] = '\0';
      return buffer;
    }

    int ch = (int) ((unsigned char) text[i]);

    buffer[i*2] = HexTable[ch >> 4]; // ch/16
    buffer[i*2+1] = HexTable[ch & 0xF]; // ch % 16
  }

  buffer[(i)*2] = '\0';

  return buffer;
}

static char testBuffer[10000];

int main()
{
  char digest[256];
  char *hex_string;

  int i = 0;
  //init uart
  uart_init(UART_BASE,FREQ/BAUD);   

  //init timer
  timer_init(TIMER_BASE);
#ifdef PROFILE
  PROF_START(global)
    PROF_START(printf)
#endif
  printf("[L = %d]\n", HASH_SIZE);
#ifdef PROFILE
  PROF_STOP(printf)
#endif

  //Message test loop
  for(i=0; i< NUM_MSGS; i++){

#ifdef PROFILE
    PROF_START(sha256)
#endif
    sha256(digest,msg_array[i],msg_len[i]);
#ifdef PROFILE
    PROF_STOP(sha256)
    PROF_START(GetHexadecimal)
#endif
    hex_string = GetHexadecimal(msg_array[i], (msg_len[i]) ? msg_len[i] : 1);
#ifdef PROFILE
    PROF_STOP(GetHexadecimal)
    PROF_START(printf)
#endif
    printf("\nLen = %d\n", msg_len[i]*8);
    printf("Msg = %s\n", hex_string);
#ifdef PROFILE
    PROF_STOP(printf)
    PROF_START(GetHexadecimal)
#endif
    hex_string = GetHexadecimal(digest, HASH_SIZE);
#ifdef PROFILE
    PROF_STOP(GetHexadecimal)
    PROF_START(printf)
#endif
    printf("MD = %s\n", GetHexadecimal(digest, HASH_SIZE));
#ifdef PROFILE
    PROF_STOP(printf)
#endif

  }

#ifdef PROFILE
    PROF_START(printf)
#endif
  printf("\n");
#ifdef PROFILE
    PROF_STOP(printf)
  // Finish profile and report execution times
  PROF_STOP(global)
  profile_report();
#endif

  uart_finish();
}
