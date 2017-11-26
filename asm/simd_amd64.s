
#include "textflag.h"

// Based on Chewxy vec64f
// func VecMul(a, b, out []float64)
TEXT ·VecMulf32x4(SB), $0-72

	MOVQ a_base+0(FP), SI
	MOVQ b_base+24(FP), R15
	MOVQ out_base+48(FP),DI   // Destination

	MOVQ a_len+8(FP), AX    // len(a) into AX
	MOVQ b_len+32(FP), BX   // len(b) into BX
	MOVQ out_len+56(FP), DX // len(out) into DX

	// check if they are the same length
	CMPQ AX, BX
	JNE  panic  // jump to panic if not the same length. TODO: return bloody errors
	CMPQ AX, DX
	JNE  panic  // jump to panic if not the same length. TODO: return bloody errors
	

	// check if there are at least 8 elements
	SUBQ $16, AX
	JL   remainder

loop:
	// a[0]
	MOVUPS (SI), X0    // Take 4 float32s  to X0
	MOVUPS (R15), X1
	MULPS  X0, X1
	MOVUPS X1, (DI) 
	
	MOVUPS 16(SI), X2    // Next 16 bytes (each float32 is 4) - 8 float32
	MOVUPS 16(R15), X3
	MULPS  X2, X3
	MOVAPS X3, 16(DI)

	MOVAPS 32(SI), X4    // Next 16 bytes (each float32 is 4) - 8 float32
	MOVAPS 32(R15), X5
	MULPS  X4, X5
	MOVAPS X5, 32(DI)

	MOVAPS 48(SI), X6    // Next 16 bytes (each float32 is 4) - 8 float32
	MOVAPS 48(R15), X7
	MULPS  X6, X7
	MOVAPS X7, 48(DI)

	ADDQ $64, SI         // increment 4 iterations 4 * 16
	ADDQ $64, DI
	ADDQ $64, R15

	SUBQ $16, AX         // Count down 4*4 floats
	JGE  loop            // Repeat

remainder:
	ADDQ $16, AX
	JE   done

remainderloop:

	MOVSS (SI), X0
	MOVSS (R15), X1
	MULSS X0, X1
	MOVSS X1, (DI)

	// update pointer to the top of the data
	ADDQ $4, SI
	ADDQ $4, DI
	ADDQ $4, R15

	DECQ AX
	JNE  remainderloop

done:
	RET

panic:
	CALL runtime·panicindex(SB)
	RET
