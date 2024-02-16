@.printFloat = private unnamed_addr constant [7 x i8] c"%.10f\0A\00"

declare i32 @printf(ptr noalias nocapture, ...)
declare double @pow(double noundef, double noundef) 

define i32 @factorial(i32) local_unnamed_addr #0 {
    %r = alloca i32
    store i32 1, ptr %r

    %arg = alloca i32
    store i32 %0, ptr %arg
    br label %ForCheck
ForCheck:
    %argTempFC = load i32, ptr %arg
    %eqone = icmp eq i32 %argTempFC, 1
    br i1 %eqone, label %Done, label %ForBody
ForBody:
    %argTempFB = load i32, ptr %arg
    %rtemp = load i32, ptr %r
    
    %result = mul i32 %argTempFB, %rtemp
    store i32 %result, ptr %r

    %argTemp = load i32, ptr %arg
    %resultSub = sub i32 %argTemp, 1
    store i32 %resultSub, ptr %arg

    br label %ForCheck
Done:
    %argTempRet = load i32, ptr %r
    ret i32 %argTempRet
}

define double @sin(double %inp, i8 %precision) { ; iterations is how many iterations of taylor series to do
    %direction = alloca i1
    store i1 1, ptr %direction ; if direction is true/1, then we add, otherwise subtract

    %iterations = alloca i8 
    store i8 %precision, ptr %iterations

    %runningValue = alloca double, align 4 ; running value
    store double 0.0, ptr %runningValue

    %exp = alloca i32 ; running exponent
    store i32 1, ptr %exp


    br label %PrecisionCheck
PrecisionCheck:
    %precisionPC = load i8, ptr %iterations
    %done = icmp eq i8 %precisionPC, 0
    br i1 %done, label %ReturnSin, label %TaylorBody
TaylorBody:
    %tempExp = load i32, ptr %exp
    %tempExpFloat = sitofp i32 %tempExp to double
    %sum = call double @pow(double %inp, double %tempExpFloat) ; x^exp

    ; divide by exp factorial

    %divisor = call i32 @factorial(i32 %tempExp)
    %divisorFloat = sitofp i32 %divisor to double

    %nextElement = fdiv double %sum, %divisorFloat

    ; now do we add or subtract?

    %directionCheck = load i1, ptr %direction
    %runningValueTemp = load double, ptr %runningValue
    br i1 %directionCheck, label %Add, label %Subtract
Add:
    %runningValueUpdatedAdd = fadd double %runningValueTemp, %nextElement
    store double %runningValueUpdatedAdd, ptr %runningValue
    br label %endLoop
Subtract:
    %runningValueUpdatedSub = fsub double %runningValueTemp, %nextElement
    store double %runningValueUpdatedSub, ptr %runningValue
    br label %endLoop
endLoop:
    ; decrement precision
    %precisionTemp = load i8, ptr %iterations
    %newPrecisionTemp = sub i8 %precisionTemp, 1
    store i8 %newPrecisionTemp, ptr %iterations
    ; reverse direction
    %directionTemp = load i1, ptr %direction
    %newDirectionTemp = add i1 %directionTemp, 1
    store i1 %newDirectionTemp, ptr %direction
    ; don't forget to increment exp by 2!!!!
    %expTemp = load i32, ptr %exp
    %newExpTemp = add i32 %expTemp, 2
    store i32 %newExpTemp, ptr %exp
    ; jump back
    br label %PrecisionCheck
ReturnSin:
    %runningValueRet = load double, ptr %runningValue

    ret double %runningValueRet
}

define i32 @main() #0 {
    %result = call double @sin(double 1.0, i8 17)
    call i32 (ptr, ...) @printf(ptr noundef @.printFloat, double noundef %result)
    ret i32 0
}
