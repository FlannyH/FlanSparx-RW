SECTION "Sprite Handler", ROM0

;Update the player sprite, copy shadow OAM to real OAM, and flip the half timer
HandleSprites:
    ;Copy sprites to OAM
    ld  a, HIGH(wShadowOAM)
    di
    call hOAMDMA
    ei

    ;Flip the half timer
    ld a, [bBooleans]
    xor (1<<B_HALFTIMER)
    ld [bBooleans], a

    ret
    

;CREDIT TO https://gbdev.gg8.se/wiki/articles/OAM_DMA_tutorial
SECTION "OAM DMA routine", ROM0
CopyDMARoutine:
  ld  hl, DMARoutine
  ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
  ld  c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
  ld  a, [hl+]
  ldh [c], a
  inc c
  dec b
  jr  nz, .copy
  ret

DMARoutine:
  ldh [rDMA], a
  
  ld  a, 40
.wait
  dec a
  jr  nz, .wait
  ret
DMARoutineEnd:

SECTION "OAM DMA", HRAM

hOAMDMA::
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to