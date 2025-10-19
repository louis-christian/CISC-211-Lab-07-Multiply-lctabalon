/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Louis Christian Tabalon"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    /* this code initializes all the required variables to zero */
    mov r2, 0              /* r2 is set as the zero constant for initialization */

    ldr r3, =rng_Error
    str r2, [r3]            /* stores 0 into the rng_Error mem location */

    ldr r3, =a_Multiplicand
    str r2, [r3]            /* stores 0 into the a_Multiplicand mem location */

    ldr r3, =b_Multiplier
    str r2, [r3]            /* stores 0 into the b_Multiplier mem location */

    ldr r3, =a_Sign
    str r2, [r3]            /* stores 0 into the a_Sign mem location */

    ldr r3, =b_Sign
    str r2, [r3]            /* stores 0 into the b_Sign mem location */

    ldr r3, =prod_Is_Neg
    str r2, [r3]            /* stores 0 into the prod_Is_Neg mem location */

    ldr r3, =a_Abs
    str r2, [r3]            /* stores 0 into the a_Abs mem location */

    ldr r3, =b_Abs
    str r2, [r3]            /* stores 0 into the b_Abs mem location */

    ldr r3, =init_Product
    str r2, [r3]            /* stores 0 into the init_Product mem location */

    ldr r3, =final_Product
    str r2, [r3]            /* stores 0 into the final_Product mem location */
    
    
    /* copies the original inputs from r0 and r1 into memory */
    ldr r3, =a_Multiplicand /* loads the mem address of 'a_Multiplicand' to r3 */
    str r0, [r3]            /* stores the multiplicand (r0) into mem location */

    ldr r3, =b_Multiplier   /* loads the mem address of 'b_Multiplier' to r3 */
    str r1, [r3]            /* stores the multiplier (r1) into mem location */


    /* this code checks if the inputs are within signed 16-bit range */
    /* the range is -32768 to 32767 */
    
    /* check r0 lower bound: r0 < -32768 */
    ldr r4, =-32768         /* r4 is set to the lower bound (-32768) */
    cmp r0, r4              /* compares r0 with -32768 */
    blt range_error_a       /* branches if r0 is less than the lower bound */
    
    /* check r0 upper bound: r0 > 32767 */
    ldr r4, =32767          /* r4 is set to the upper bound (32767) */
    cmp r0, r4              /* compares r0 with 32767 */
    bgt range_error_a       /* branches if r0 is greater than the upper bound */

range_ok_a:
    /* check r1 lower bound: r1 < -32768 */
    ldr r4, =-32768         /* r4 is set to the lower bound (-32768) */
    cmp r1, r4              /* compares r1 with -32768 */
    blt range_error_b       /* branches if r1 is less than the lower bound */
    
    /* check r1 upper bound: r1 > 32767 */
    ldr r4, =32767          /* r4 is set to the upper bound (32767) */
    cmp r1, r4              /* compares r1 with 32767 */
    bgt range_error_b       /* branches if r1 is greater than the upper bound */
    
    b sign_check            /* if both are in range, proceed to sign handling */

range_error_a:
    /* this code handles the range error case */
    ldr r3, =rng_Error      /* loads the mem address of 'rng_Error' to r3 */
    mov r4, 1
    str r4, [r3]            /* sets rng_Error to 1 */
    mov r0, 0              /* sets r0 to 0 before exiting */
    b done                  /* jumps to the exit point */
    
range_error_b:
    /* this code handles the range error case */
    ldr r3, =rng_Error      /* loads the mem address of 'rng_Error' to r3 */
    mov r4, 1
    str r4, [r3]            /* sets rng_Error to 1 */
    mov r0, 0              /* sets r0 to 0 before exiting */
    b done                  /* jumps to the exit point */

sign_check:
    /* this code determines and stores the sign for a and b, and the final product sign */
    
    mov r4, 0              /* r4 is set to 0 (assume positive sign) */
    cmp r0, 0              /* checks if r0 is positive or negative */
    bge a_pos               /* branches if r0 is positive or zero */
    mov r4, 1              /* r4 is set to 1 (negative sign) */

a_pos:
    ldr r3, =a_Sign         /* loads the mem address of 'a_Sign' to r3 */
    str r4, [r3]            /* stores the a_Sign value (0 or 1) into memory */

    mov r5, 0              /* r5 is set to 0 (assume positive sign) */
    cmp r1, 0              /* checks if r1 is positive or negative */
    bge b_pos               /* branches if r1 is positive or zero */
    mov r5, #1              /* r5 is set to 1 (negative sign) */

b_pos:
    ldr r3, =b_Sign         /* loads the mem address of 'b_Sign' to r3 */
    str r5, [r3]            /* stores the b_Sign value (0 or 1) into memory */

    eor r6, r4, r5          /* xors a_Sign (r4) and b_Sign (r5) to find if signs differ (1=neg) */
    
    /* if either input is 0, the product is 0 and should be positive */
    cmp r0, 0
    beq prod_is_zero        /* branches if r0 is zero */
    cmp r1, 0
    beq prod_is_zero        /* branches if r1 is zero */

    ldr r3, =prod_Is_Neg    /* loads the mem address of 'prod_Is_Neg' to r3 */
    str r6, [r3]            /* stores the product sign (r6) into memory */
    b abs_values            /* proceeds to calculate absolute values */

prod_is_zero:
    ldr r3, =prod_Is_Neg
    mov r6, 0              /* r6 is set to 0 (product of 0 is positive) */
    str r6, [r3]            /* stores 0 into prod_Is_Neg mem location */
    
abs_values:
    /* this code negates if necessary to get the absolute values */
    
    cmp r0, 0
    bge r0_is_abs           /* skips negation if r0 is already positive or zero */
    rsb r0, r0, 0          /* r0 = 0 - r0 (takes the absolute value, two's complement) */

r0_is_abs:
    ldr r3, =a_Abs          /* loads the mem address of 'a_Abs' to r3 */
    str r0, [r3]            /* stores the a_Abs value into memory */

    cmp r1, 0
    bge r1_is_abs           /* skips negation if r1 is already positive or zero */
    rsb r1, r1, 0          /* r1 = 0 - r1 (takes the absolute value) */

r1_is_abs:
    ldr r3, =b_Abs          /* loads the mem address of 'b_Abs' to r3 */
    str r1, [r3]            /* stores the b_Abs value into memory */
    
    /* r0 now holds the positive multiplicand (a_abs) */
    /* r1 now holds the positive multiplier (b_abs) */

    /* this code executes the shift-and-add algorithm */
    
    mov r2, 0              /* r2 is the running product, initialized to zero */
    mov r3, 16             /* r3 is the 16-bit loop counter */

mult_loop:
    and r4, r1, 1          /* r4 gets the least significant bit (lsb) of multiplier (r1) */
    cmp r4, #1              /* checks if the lsb is 1 */
    beq add_multiplicand    /* branches if lsb is 1 (add r0 to r2) */

no_add:
    lsl r0, r0, 1          /* multiplicand (r0) shifts left by 1 */
    lsr r1, r1, 1          /* multiplier (r1) shifts right by 1 */
    subs r3, r3, 1         /* decrements the loop counter and sets flags */
    bne mult_loop           /* loops back if the counter is not zero */
    b mult_done             /* multiplication finished after 16 iterations */

add_multiplicand:
    add r2, r2, r0          /* r2 = r2 + r0 (product += multiplicand) */
    b no_add                /* continues with the shifting operations */

mult_done:
    /* store the intermediate positive product */
    ldr r3, =init_Product
    str r2, [r3]            /* stores the positive r2 (init_Product) into mem location */

    /* this code applies the final sign to the product if prod_is_neg is 1 */
    ldr r3, =prod_Is_Neg
    ldr r4, [r3]            /* loads the prod_Is_Neg value into r4 */

    cmp r4, 1              /* checks if the product should be negative */
    bne final_sign_done     /* skips negation if r4 is 0 (positive result) */

    rsb r2, r2, 0          /* r2 = 0 - r2 (negates the positive product) */

final_sign_done:
    /* store final product and prepare r0 for return */
    ldr r3, =final_Product
    str r2, [r3]            /* stores the final product (r2) into mem location */

    mov r0, r2              /* copies the final result to r0 for the return value */
    
    
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




