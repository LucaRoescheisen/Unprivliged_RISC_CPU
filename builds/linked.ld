/* This linker script is a WIP, will be completed once CSRs are done  */
SECTIONS {

  . = 0x00000000;
  .text.boot : { *(text.boot)}

  . = 0x00000100;
  .text.trap : { *(text.trap)}

}