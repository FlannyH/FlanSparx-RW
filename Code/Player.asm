Section "Player Handler"
ObjUpdate_Player:
    call GetJoypadStatus
    ;Up
    ld a, [joypad_current]
    bit J_UP, a
    call nz, ScrollUp

    ;Down
    ld a, [joypad_current]
    bit J_DOWN, a
    call nz, ScrollDown

    ;Right
    ld a, [joypad_current]
    bit J_RIGHT, a
    call nz, ScrollRight

    ;Left
    ld a, [joypad_current]
    bit J_LEFT, a
    call nz, ScrollLeft
    ret