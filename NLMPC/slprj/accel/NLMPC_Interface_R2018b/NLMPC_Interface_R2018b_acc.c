#include "__cf_NLMPC_Interface_R2018b.h"
#include <math.h>
#include "NLMPC_Interface_R2018b_acc.h"
#include "NLMPC_Interface_R2018b_acc_private.h"
#include <stdio.h>
#include "slexec_vm_simstruct_bridge.h"
#include "slexec_vm_zc_functions.h"
#include "slexec_vm_lookup_functions.h"
#include "slsv_diagnostic_codegen_c_api.h"
#include "simstruc.h"
#include "fixedpoint.h"
#define CodeFormat S-Function
#define AccDefine1 Accelerator_S-Function
#include "simtarget/slAccSfcnBridge.h"
#ifndef __RTW_UTFREE__  
extern void * utMalloc ( size_t ) ; extern void utFree ( void * ) ;
#endif
boolean_T NLMPC_Interface_R2018b_acc_rt_TDelayUpdateTailOrGrowBuf ( int_T *
bufSzPtr , int_T * tailPtr , int_T * headPtr , int_T * lastPtr , real_T
tMinusDelay , real_T * * tBufPtr , real_T * * uBufPtr , real_T * * xBufPtr ,
boolean_T isfixedbuf , boolean_T istransportdelay , int_T * maxNewBufSzPtr )
{ int_T testIdx ; int_T tail = * tailPtr ; int_T bufSz = * bufSzPtr ; real_T
* tBuf = * tBufPtr ; real_T * xBuf = ( NULL ) ; int_T numBuffer = 2 ; if (
istransportdelay ) { numBuffer = 3 ; xBuf = * xBufPtr ; } testIdx = ( tail <
( bufSz - 1 ) ) ? ( tail + 1 ) : 0 ; if ( ( tMinusDelay <= tBuf [ testIdx ] )
&& ! isfixedbuf ) { int_T j ; real_T * tempT ; real_T * tempU ; real_T *
tempX = ( NULL ) ; real_T * uBuf = * uBufPtr ; int_T newBufSz = bufSz + 1024
; if ( newBufSz > * maxNewBufSzPtr ) { * maxNewBufSzPtr = newBufSz ; } tempU
= ( real_T * ) utMalloc ( numBuffer * newBufSz * sizeof ( real_T ) ) ; if (
tempU == ( NULL ) ) { return ( false ) ; } tempT = tempU + newBufSz ; if (
istransportdelay ) tempX = tempT + newBufSz ; for ( j = tail ; j < bufSz ; j
++ ) { tempT [ j - tail ] = tBuf [ j ] ; tempU [ j - tail ] = uBuf [ j ] ; if
( istransportdelay ) tempX [ j - tail ] = xBuf [ j ] ; } for ( j = 0 ; j <
tail ; j ++ ) { tempT [ j + bufSz - tail ] = tBuf [ j ] ; tempU [ j + bufSz -
tail ] = uBuf [ j ] ; if ( istransportdelay ) tempX [ j + bufSz - tail ] =
xBuf [ j ] ; } if ( * lastPtr > tail ) { * lastPtr -= tail ; } else { *
lastPtr += ( bufSz - tail ) ; } * tailPtr = 0 ; * headPtr = bufSz ; utFree (
uBuf ) ; * bufSzPtr = newBufSz ; * tBufPtr = tempT ; * uBufPtr = tempU ; if (
istransportdelay ) * xBufPtr = tempX ; } else { * tailPtr = testIdx ; }
return ( true ) ; } real_T NLMPC_Interface_R2018b_acc_rt_TDelayInterpolate (
real_T tMinusDelay , real_T tStart , real_T * tBuf , real_T * uBuf , int_T
bufSz , int_T * lastIdx , int_T oldestIdx , int_T newIdx , real_T initOutput
, boolean_T discrete , boolean_T minorStepAndTAtLastMajorOutput ) { int_T i ;
real_T yout , t1 , t2 , u1 , u2 ; if ( ( newIdx == 0 ) && ( oldestIdx == 0 )
&& ( tMinusDelay > tStart ) ) return initOutput ; if ( tMinusDelay <= tStart
) return initOutput ; if ( ( tMinusDelay <= tBuf [ oldestIdx ] ) ) { if (
discrete ) { return ( uBuf [ oldestIdx ] ) ; } else { int_T tempIdx =
oldestIdx + 1 ; if ( oldestIdx == bufSz - 1 ) tempIdx = 0 ; t1 = tBuf [
oldestIdx ] ; t2 = tBuf [ tempIdx ] ; u1 = uBuf [ oldestIdx ] ; u2 = uBuf [
tempIdx ] ; if ( t2 == t1 ) { if ( tMinusDelay >= t2 ) { yout = u2 ; } else {
yout = u1 ; } } else { real_T f1 = ( t2 - tMinusDelay ) / ( t2 - t1 ) ;
real_T f2 = 1.0 - f1 ; yout = f1 * u1 + f2 * u2 ; } return yout ; } } if (
minorStepAndTAtLastMajorOutput ) { if ( newIdx != 0 ) { if ( * lastIdx ==
newIdx ) { ( * lastIdx ) -- ; } newIdx -- ; } else { if ( * lastIdx == newIdx
) { * lastIdx = bufSz - 1 ; } newIdx = bufSz - 1 ; } } i = * lastIdx ; if (
tBuf [ i ] < tMinusDelay ) { while ( tBuf [ i ] < tMinusDelay ) { if ( i ==
newIdx ) break ; i = ( i < ( bufSz - 1 ) ) ? ( i + 1 ) : 0 ; } } else { while
( tBuf [ i ] >= tMinusDelay ) { i = ( i > 0 ) ? i - 1 : ( bufSz - 1 ) ; } i =
( i < ( bufSz - 1 ) ) ? ( i + 1 ) : 0 ; } * lastIdx = i ; if ( discrete ) {
double tempEps = ( DBL_EPSILON ) * 128.0 ; double localEps = tempEps *
muDoubleScalarAbs ( tBuf [ i ] ) ; if ( tempEps > localEps ) { localEps =
tempEps ; } localEps = localEps / 2.0 ; if ( tMinusDelay >= ( tBuf [ i ] -
localEps ) ) { yout = uBuf [ i ] ; } else { if ( i == 0 ) { yout = uBuf [
bufSz - 1 ] ; } else { yout = uBuf [ i - 1 ] ; } } } else { if ( i == 0 ) {
t1 = tBuf [ bufSz - 1 ] ; u1 = uBuf [ bufSz - 1 ] ; } else { t1 = tBuf [ i -
1 ] ; u1 = uBuf [ i - 1 ] ; } t2 = tBuf [ i ] ; u2 = uBuf [ i ] ; if ( t2 ==
t1 ) { if ( tMinusDelay >= t2 ) { yout = u2 ; } else { yout = u1 ; } } else {
real_T f1 = ( t2 - tMinusDelay ) / ( t2 - t1 ) ; real_T f2 = 1.0 - f1 ; yout
= f1 * u1 + f2 * u2 ; } } return ( yout ) ; } void rt_ssGetBlockPath (
SimStruct * S , int_T sysIdx , int_T blkIdx , char_T * * path ) {
_ssGetBlockPath ( S , sysIdx , blkIdx , path ) ; } void rt_ssSet_slErrMsg (
SimStruct * S , void * diag ) { if ( ! _ssIsErrorStatusAslErrMsg ( S ) ) {
_ssSet_slErrMsg ( S , diag ) ; } else { _ssDiscardDiagnostic ( S , diag ) ; }
} void rt_ssReportDiagnosticAsWarning ( SimStruct * S , void * diag ) {
_ssReportDiagnosticAsWarning ( S , diag ) ; } static void mdlOutputs (
SimStruct * S , int_T tid ) { boolean_T B_11_11_0 ; boolean_T B_11_13_0 ;
real_T rtb_B_8_1_0 ; int32_T i ; int32_T i_0 ; B_NLMPC_Interface_R2018b_T *
_rtB ; P_NLMPC_Interface_R2018b_T * _rtP ; X_NLMPC_Interface_R2018b_T * _rtX
; DW_NLMPC_Interface_R2018b_T * _rtDW ; _rtDW = ( (
DW_NLMPC_Interface_R2018b_T * ) ssGetRootDWork ( S ) ) ; _rtX = ( (
X_NLMPC_Interface_R2018b_T * ) ssGetContStates ( S ) ) ; _rtP = ( (
P_NLMPC_Interface_R2018b_T * ) ssGetModelRtp ( S ) ) ; _rtB = ( (
B_NLMPC_Interface_R2018b_T * ) _ssGetModelBlockIO ( S ) ) ; i = ssIsSampleHit
( S , 1 , 0 ) ; if ( i != 0 ) { ssCallAccelRunBlock ( S , 11 , 0 ,
SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock ( S , 11 , 1 ,
SS_CALL_MDL_OUTPUTS ) ; _rtB -> B_11_3_0 = _rtP -> P_18 * _rtB -> B_11_0_0 *
_rtP -> P_19 ; _rtB -> B_11_4_0 = _rtP -> P_20 ; _rtB -> B_11_5_0 = _rtP ->
P_21 ; _rtB -> B_11_7_0 = _rtP -> P_22 * _rtB -> B_11_1_0 * _rtP -> P_23 ;
_rtB -> B_11_8_0 = _rtP -> P_24 ; _rtB -> B_11_9_0 = _rtP -> P_25 ; B_11_11_0
= _rtP -> P_90 ; if ( ssIsMajorTimeStep ( S ) != 0 ) { if ( B_11_11_0 ) { if
( ! _rtDW -> Correct1_MODE ) { if ( ssGetTaskTime ( S , 1 ) != ssGetTStart (
S ) ) { ssSetBlockStateForSolverChangedAtMajorStep ( S ) ; }
ssCallAccelRunBlock ( S , 0 , 0 , SS_CALL_RTW_GENERATED_ENABLE ) ; _rtDW ->
Correct1_MODE = true ; } } else { if ( _rtDW -> Correct1_MODE ) {
ssSetBlockStateForSolverChangedAtMajorStep ( S ) ; ssCallAccelRunBlock ( S ,
0 , 0 , SS_CALL_RTW_GENERATED_DISABLE ) ; _rtDW -> Correct1_MODE = false ; }
} } if ( _rtDW -> Correct1_MODE ) { vm_ReadLocalDSMNoIdx ( S , _rtDW ->
dsmIdx_f , ( char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Correct1/Data Store ReadX" ,
0 ) ; _rtB -> B_1_0_0 [ 0 ] = _rtDW -> x [ 0 ] ; _rtB -> B_1_0_0 [ 1 ] =
_rtDW -> x [ 1 ] ; _rtB -> B_1_0_0 [ 2 ] = _rtDW -> x [ 2 ] ; _rtB -> B_1_0_0
[ 3 ] = _rtDW -> x [ 3 ] ; vm_ReadLocalDSMNoIdx ( S , _rtDW -> dsmIdx , (
char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Correct1/Data Store ReadP" ,
0 ) ; memcpy ( & _rtB -> B_1_1_0 [ 0 ] , & _rtDW -> P [ 0 ] , sizeof ( real_T
) << 4U ) ; ssCallAccelRunBlock ( S , 0 , 0 , SS_CALL_MDL_OUTPUTS ) ; memcpy
( & _rtDW -> P [ 0 ] , & _rtB -> B_0_0_2 [ 0 ] , sizeof ( real_T ) << 4U ) ;
vm_WriteLocalDSMNoIdx ( S , _rtDW -> dsmIdx , ( char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Correct1/Data Store WriteP" ,
0 ) ; _rtDW -> x [ 0 ] = _rtB -> B_0_0_1 [ 0 ] ; _rtDW -> x [ 1 ] = _rtB ->
B_0_0_1 [ 1 ] ; _rtDW -> x [ 2 ] = _rtB -> B_0_0_1 [ 2 ] ; _rtDW -> x [ 3 ] =
_rtB -> B_0_0_1 [ 3 ] ; vm_WriteLocalDSMNoIdx ( S , _rtDW -> dsmIdx_f , (
char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Correct1/Data Store WriteX" ,
0 ) ; if ( ssIsMajorTimeStep ( S ) != 0 ) { srUpdateBC ( _rtDW ->
Correct1_SubsysRanBC ) ; } } B_11_13_0 = _rtP -> P_91 ; if (
ssIsMajorTimeStep ( S ) != 0 ) { if ( B_11_13_0 ) { if ( ! _rtDW ->
Correct2_MODE ) { if ( ssGetTaskTime ( S , 1 ) != ssGetTStart ( S ) ) {
ssSetBlockStateForSolverChangedAtMajorStep ( S ) ; } ssCallAccelRunBlock ( S
, 2 , 0 , SS_CALL_RTW_GENERATED_ENABLE ) ; _rtDW -> Correct2_MODE = true ; }
} else { if ( _rtDW -> Correct2_MODE ) {
ssSetBlockStateForSolverChangedAtMajorStep ( S ) ; ssCallAccelRunBlock ( S ,
2 , 0 , SS_CALL_RTW_GENERATED_DISABLE ) ; _rtDW -> Correct2_MODE = false ; }
} } if ( _rtDW -> Correct2_MODE ) { vm_ReadLocalDSMNoIdx ( S , _rtDW ->
dsmIdx_f , ( char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Correct2/Data Store ReadX" ,
0 ) ; _rtB -> B_3_0_0 [ 0 ] = _rtDW -> x [ 0 ] ; _rtB -> B_3_0_0 [ 1 ] =
_rtDW -> x [ 1 ] ; _rtB -> B_3_0_0 [ 2 ] = _rtDW -> x [ 2 ] ; _rtB -> B_3_0_0
[ 3 ] = _rtDW -> x [ 3 ] ; vm_ReadLocalDSMNoIdx ( S , _rtDW -> dsmIdx , (
char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Correct2/Data Store ReadP" ,
0 ) ; memcpy ( & _rtB -> B_3_1_0 [ 0 ] , & _rtDW -> P [ 0 ] , sizeof ( real_T
) << 4U ) ; ssCallAccelRunBlock ( S , 2 , 0 , SS_CALL_MDL_OUTPUTS ) ; memcpy
( & _rtDW -> P [ 0 ] , & _rtB -> B_2_0_2 [ 0 ] , sizeof ( real_T ) << 4U ) ;
vm_WriteLocalDSMNoIdx ( S , _rtDW -> dsmIdx , ( char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Correct2/Data Store WriteP" ,
0 ) ; _rtDW -> x [ 0 ] = _rtB -> B_2_0_1 [ 0 ] ; _rtDW -> x [ 1 ] = _rtB ->
B_2_0_1 [ 1 ] ; _rtDW -> x [ 2 ] = _rtB -> B_2_0_1 [ 2 ] ; _rtDW -> x [ 3 ] =
_rtB -> B_2_0_1 [ 3 ] ; vm_WriteLocalDSMNoIdx ( S , _rtDW -> dsmIdx_f , (
char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Correct2/Data Store WriteX" ,
0 ) ; if ( ssIsMajorTimeStep ( S ) != 0 ) { srUpdateBC ( _rtDW ->
Correct2_SubsysRanBC ) ; } } vm_ReadLocalDSMNoIdx ( S , _rtDW -> dsmIdx_f , (
char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Output/Data Store Read" , 0 )
; _rtB -> B_4_0_0 [ 0 ] = _rtDW -> x [ 0 ] ; _rtB -> B_4_0_0 [ 1 ] = _rtDW ->
x [ 1 ] ; _rtB -> B_4_0_0 [ 2 ] = _rtDW -> x [ 2 ] ; _rtB -> B_4_0_0 [ 3 ] =
_rtDW -> x [ 3 ] ; vm_ReadLocalDSMNoIdx ( S , _rtDW -> dsmIdx , ( char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Output/Data Store Read1" , 0
) ; _rtB -> B_4_2_0 = _rtB -> B_2_0_3 ; } { real_T * * uBuffer = ( real_T * *
) & _rtDW -> TransportDelay_PWORK . TUbufferPtrs [ 0 ] ; real_T * * tBuffer =
( real_T * * ) & _rtDW -> TransportDelay_PWORK . TUbufferPtrs [ 1 ] ; real_T
simTime = ssGetT ( S ) ; real_T tMinusDelay = simTime - _rtP -> P_27 ; _rtB
-> B_11_17_0 = NLMPC_Interface_R2018b_acc_rt_TDelayInterpolate ( tMinusDelay
, 0.0 , * tBuffer , * uBuffer , _rtDW -> TransportDelay_IWORK .
CircularBufSize , & _rtDW -> TransportDelay_IWORK . Last , _rtDW ->
TransportDelay_IWORK . Tail , _rtDW -> TransportDelay_IWORK . Head , _rtP ->
P_28 , 1 , ( boolean_T ) ( ssIsMinorTimeStep ( S ) && ( ssGetTimeOfLastOutput
( S ) == ssGetT ( S ) ) ) ) ; } i = ssIsSampleHit ( S , 2 , 0 ) ; if ( i != 0
) { _rtB -> B_11_18_0 = _rtB -> B_11_17_0 ; for ( i = 0 ; i < 8 ; i ++ ) {
_rtB -> B_11_35_0 [ i ] = _rtB -> B_11_34_0 [ i ] * _rtB -> B_11_18_0 ; if (
_rtDW -> icLoad != 0 ) { _rtDW -> mv_Delay_DSTATE [ i ] = _rtB -> B_11_35_0 [
i ] ; } } for ( i = 0 ; i < 6 ; i ++ ) { _rtB -> B_11_38_0 [ i ] = _rtDW ->
mv_Delay_DSTATE [ ( int32_T ) _rtB -> B_11_37_0 [ i ] - 1 ] ; } } i =
ssIsSampleHit ( S , 1 , 0 ) ; if ( i != 0 ) { for ( i = 0 ; i < 8 ; i ++ ) {
_rtB -> B_11_39_0 [ i ] = _rtB -> B_11_34_0 [ i ] * _rtB -> B_4_0_0 [ 0 ] ;
_rtB -> B_11_39_0 [ i + 8 ] = _rtB -> B_11_34_0 [ i ] * _rtB -> B_4_0_0 [ 1 ]
; _rtB -> B_11_39_0 [ i + 16 ] = _rtB -> B_11_34_0 [ i ] * _rtB -> B_4_0_0 [
2 ] ; _rtB -> B_11_39_0 [ i + 24 ] = _rtB -> B_11_34_0 [ i ] * _rtB ->
B_4_0_0 [ 3 ] ; } } i = ssIsSampleHit ( S , 2 , 0 ) ; if ( i != 0 ) { if (
_rtDW -> icLoad_f != 0 ) { memcpy ( & _rtDW -> x_Delay_DSTATE [ 0 ] , & _rtB
-> B_11_39_0 [ 0 ] , sizeof ( real_T ) << 5U ) ; } for ( i = 0 ; i < 4 ; i ++
) { for ( i_0 = 0 ; i_0 < 6 ; i_0 ++ ) { _rtB -> B_11_42_0 [ i_0 + 6 * i ] =
_rtDW -> x_Delay_DSTATE [ ( ( i << 3 ) + ( int32_T ) _rtB -> B_11_41_0 [ i_0
] ) - 1 ] ; } } if ( _rtDW -> icLoad_g != 0 ) { _rtDW -> slack_delay_DSTATE =
_rtB -> B_11_43_0 ; } _rtB -> B_11_44_0 = _rtDW -> slack_delay_DSTATE ;
ssCallAccelRunBlock ( S , 7 , 0 , SS_CALL_MDL_OUTPUTS ) ; } i = ssIsSampleHit
( S , 1 , 0 ) ; if ( i != 0 ) { { _rtB -> B_11_46_0 = 0 ; }
ssCallAccelRunBlock ( S , 11 , 47 , SS_CALL_MDL_OUTPUTS ) ; { if ( ( _rtDW ->
HiddenToAsyncQueue_InsertedFor_ExtendedKalmanFilter_at_outport_0_PWORK .
AQHandles || _rtDW ->
HiddenToAsyncQueue_InsertedFor_ExtendedKalmanFilter_at_outport_0_PWORK .
SlioLTF ) && ssGetLogOutput ( S ) ) { sdiSlioSdiWriteSignal ( _rtDW ->
HiddenToAsyncQueue_InsertedFor_ExtendedKalmanFilter_at_outport_0_PWORK .
AQHandles , _rtDW ->
HiddenToAsyncQueue_InsertedFor_ExtendedKalmanFilter_at_outport_0_PWORK .
SlioLTF , 0 , ssGetTaskTime ( S , 1 ) , ( void * ) & _rtB -> B_4_0_0 [ 0 ] )
; } } } i = ssIsSampleHit ( S , 2 , 0 ) ; if ( i != 0 ) { { if ( ( _rtDW ->
HiddenToAsyncQueue_InsertedFor_NonlinearMPCController_at_outport_0_PWORK .
AQHandles || _rtDW ->
HiddenToAsyncQueue_InsertedFor_NonlinearMPCController_at_outport_0_PWORK .
SlioLTF ) && ssGetLogOutput ( S ) ) { sdiSlioSdiWriteSignal ( _rtDW ->
HiddenToAsyncQueue_InsertedFor_NonlinearMPCController_at_outport_0_PWORK .
AQHandles , _rtDW ->
HiddenToAsyncQueue_InsertedFor_NonlinearMPCController_at_outport_0_PWORK .
SlioLTF , 0 , ssGetTaskTime ( S , 2 ) , ( void * ) & _rtB -> B_7_0_1 ) ; } }
} _rtB -> B_11_50_0 = 0.0 ; _rtB -> B_11_50_0 += _rtP -> P_50 [ 0 ] * _rtX ->
DerivativeFilter_CSTATE [ 0 ] ; _rtB -> B_11_50_0 += _rtP -> P_50 [ 1 ] *
_rtX -> DerivativeFilter_CSTATE [ 1 ] ; _rtB -> B_11_51_0 = 0.0 ; _rtB ->
B_11_51_0 += _rtP -> P_52 [ 0 ] * _rtX -> DerivativeFilter1_CSTATE [ 0 ] ;
_rtB -> B_11_51_0 += _rtP -> P_52 [ 1 ] * _rtX -> DerivativeFilter1_CSTATE [
1 ] ; i = ssIsSampleHit ( S , 1 , 0 ) ; if ( i != 0 ) { ssCallAccelRunBlock (
S , 11 , 52 , SS_CALL_MDL_OUTPUTS ) ; } ssCallAccelRunBlock ( S , 11 , 53 ,
SS_CALL_MDL_OUTPUTS ) ; i = ssIsSampleHit ( S , 1 , 0 ) ; if ( i != 0 ) {
_rtB -> B_11_54_0 = _rtB -> B_7_0_1 ; { if ( ( _rtDW ->
HiddenToAsyncQueue_InsertedFor_ZeroOrderHold_at_outport_0_PWORK . AQHandles
|| _rtDW -> HiddenToAsyncQueue_InsertedFor_ZeroOrderHold_at_outport_0_PWORK .
SlioLTF ) && ssGetLogOutput ( S ) ) { sdiSlioSdiWriteSignal ( _rtDW ->
HiddenToAsyncQueue_InsertedFor_ZeroOrderHold_at_outport_0_PWORK . AQHandles ,
_rtDW -> HiddenToAsyncQueue_InsertedFor_ZeroOrderHold_at_outport_0_PWORK .
SlioLTF , 0 , ssGetTaskTime ( S , 1 ) , ( void * ) & _rtB -> B_11_54_0 ) ; }
} { if ( ( _rtDW ->
HiddenToAsyncQueue_InsertedFor_ZeroOrderHold1_at_outport_0_PWORK . AQHandles
|| _rtDW -> HiddenToAsyncQueue_InsertedFor_ZeroOrderHold1_at_outport_0_PWORK
. SlioLTF ) && ssGetLogOutput ( S ) ) { sdiSlioSdiWriteSignal ( _rtDW ->
HiddenToAsyncQueue_InsertedFor_ZeroOrderHold1_at_outport_0_PWORK . AQHandles
, _rtDW -> HiddenToAsyncQueue_InsertedFor_ZeroOrderHold1_at_outport_0_PWORK .
SlioLTF , 0 , ssGetTaskTime ( S , 1 ) , ( void * ) & _rtB -> B_11_7_0 ) ; } }
{ if ( ( _rtDW ->
HiddenToAsyncQueue_InsertedFor_ZeroOrderHold2_at_outport_0_PWORK . AQHandles
|| _rtDW -> HiddenToAsyncQueue_InsertedFor_ZeroOrderHold2_at_outport_0_PWORK
. SlioLTF ) && ssGetLogOutput ( S ) ) { sdiSlioSdiWriteSignal ( _rtDW ->
HiddenToAsyncQueue_InsertedFor_ZeroOrderHold2_at_outport_0_PWORK . AQHandles
, _rtDW -> HiddenToAsyncQueue_InsertedFor_ZeroOrderHold2_at_outport_0_PWORK .
SlioLTF , 0 , ssGetTaskTime ( S , 1 ) , ( void * ) & _rtB -> B_11_3_0 ) ; } }
memcpy ( & _rtB -> B_11_58_0 [ 0 ] , & _rtP -> P_53 [ 0 ] , sizeof ( real_T )
<< 4U ) ; vm_ReadLocalDSMNoIdx ( S , _rtDW -> dsmIdx_f , ( char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Predict/Data Store ReadX" , 0
) ; _rtB -> B_6_0_0 [ 0 ] = _rtDW -> x [ 0 ] ; _rtB -> B_6_0_0 [ 1 ] = _rtDW
-> x [ 1 ] ; _rtB -> B_6_0_0 [ 2 ] = _rtDW -> x [ 2 ] ; _rtB -> B_6_0_0 [ 3 ]
= _rtDW -> x [ 3 ] ; vm_ReadLocalDSMNoIdx ( S , _rtDW -> dsmIdx , ( char_T *
) "NLMPC_Interface_R2018b/Extended Kalman Filter /Predict/Data Store ReadP" ,
0 ) ; memcpy ( & _rtB -> B_6_1_0 [ 0 ] , & _rtDW -> P [ 0 ] , sizeof ( real_T
) << 4U ) ; ssCallAccelRunBlock ( S , 5 , 0 , SS_CALL_MDL_OUTPUTS ) ; memcpy
( & _rtDW -> P [ 0 ] , & _rtB -> B_5_0_2 [ 0 ] , sizeof ( real_T ) << 4U ) ;
vm_WriteLocalDSMNoIdx ( S , _rtDW -> dsmIdx , ( char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Predict/Data Store WriteP" ,
0 ) ; _rtDW -> x [ 0 ] = _rtB -> B_5_0_1 [ 0 ] ; _rtDW -> x [ 1 ] = _rtB ->
B_5_0_1 [ 1 ] ; _rtDW -> x [ 2 ] = _rtB -> B_5_0_1 [ 2 ] ; _rtDW -> x [ 3 ] =
_rtB -> B_5_0_1 [ 3 ] ; vm_WriteLocalDSMNoIdx ( S , _rtDW -> dsmIdx_f , (
char_T * )
"NLMPC_Interface_R2018b/Extended Kalman Filter /Predict/Data Store WriteX" ,
0 ) ; _rtB -> B_11_64_0 = ( _rtB -> B_11_63_0 == _rtB -> B_11_3_0 ) ; if (
_rtB -> B_11_64_0 > 0.0 ) { _rtB -> B_9_0_0 = _rtB -> B_11_62_0 ; if (
ssIsMajorTimeStep ( S ) != 0 ) { srUpdateBC ( _rtDW ->
Holdsstatesonceenabled_SubsysRanBC ) ; } } _rtB -> B_11_67_0 = ( ( _rtB ->
B_9_0_0 != 0.0 ) && ( _rtB -> B_11_66_0 != 0.0 ) ) ; if ( _rtB -> B_11_67_0 >
0.0 ) { rtb_B_8_1_0 = _rtP -> P_1 * _rtB -> B_11_3_0 ; if ( _rtB -> B_8_0_0 <
rtb_B_8_1_0 ) { ssSetStopRequested ( S , 1 ) ; } rtb_B_8_1_0 = ( rtb_B_8_1_0
< _rtB -> B_8_4_0 ) ; if ( rtb_B_8_1_0 != 0.0 ) { ssSetStopRequested ( S , 1
) ; } if ( ssIsMajorTimeStep ( S ) != 0 ) { srUpdateBC ( _rtDW ->
CartPendulumAngleWatchdog_SubsysRanBC ) ; } } if ( _rtB -> B_11_70_0 > 0.0 )
{ if ( _rtB -> B_10_0_0 < _rtB -> B_11_7_0 ) { ssSetStopRequested ( S , 1 ) ;
} if ( _rtB -> B_11_7_0 < _rtB -> B_10_3_0 ) { ssSetStopRequested ( S , 1 ) ;
} if ( ssIsMajorTimeStep ( S ) != 0 ) { srUpdateBC ( _rtDW ->
CartPositionWatchdog_SubsysRanBC ) ; } } if ( _rtB -> B_9_0_0 >= _rtP -> P_61
) { rtb_B_8_1_0 = _rtB -> B_7_0_1 ; } else { rtb_B_8_1_0 = _rtB -> B_11_69_0
; } rtb_B_8_1_0 *= _rtP -> P_62 ; if ( rtb_B_8_1_0 > _rtP -> P_63 ) { _rtB ->
B_11_74_0 = _rtP -> P_63 ; } else if ( rtb_B_8_1_0 < _rtP -> P_64 ) { _rtB ->
B_11_74_0 = _rtP -> P_64 ; } else { _rtB -> B_11_74_0 = rtb_B_8_1_0 ; }
ssCallAccelRunBlock ( S , 11 , 75 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 11 , 76 , SS_CALL_MDL_OUTPUTS ) ; _rtB -> B_11_77_0
= _rtP -> P_73 * _rtB -> B_11_74_0 ; ssCallAccelRunBlock ( S , 11 , 78 ,
SS_CALL_MDL_OUTPUTS ) ; _rtB -> B_11_79_0 = _rtP -> P_74 * _rtB -> B_11_3_0 ;
ssCallAccelRunBlock ( S , 11 , 80 , SS_CALL_MDL_OUTPUTS ) ; _rtB -> B_11_81_0
= _rtP -> P_75 * _rtB -> B_11_7_0 ; ssCallAccelRunBlock ( S , 11 , 82 ,
SS_CALL_MDL_OUTPUTS ) ; } UNUSED_PARAMETER ( tid ) ; } static void
mdlOutputsTID3 ( SimStruct * S , int_T tid ) { int32_T i ;
B_NLMPC_Interface_R2018b_T * _rtB ; P_NLMPC_Interface_R2018b_T * _rtP ; _rtP
= ( ( P_NLMPC_Interface_R2018b_T * ) ssGetModelRtp ( S ) ) ; _rtB = ( (
B_NLMPC_Interface_R2018b_T * ) _ssGetModelBlockIO ( S ) ) ; _rtB -> B_11_10_0
= _rtP -> P_89 ; _rtB -> B_11_19_0 = _rtP -> P_29 ; _rtB -> B_11_20_0 = _rtP
-> P_30 ; _rtB -> B_11_21_0 = _rtP -> P_31 ; _rtB -> B_11_22_0 = _rtP -> P_32
; _rtB -> B_11_16_0 [ 0 ] = _rtP -> P_26 [ 0 ] ; _rtB -> B_11_23_0 [ 0 ] =
_rtP -> P_33 [ 0 ] ; _rtB -> B_11_24_0 [ 0 ] = _rtP -> P_34 [ 0 ] ; _rtB ->
B_11_16_0 [ 1 ] = _rtP -> P_26 [ 1 ] ; _rtB -> B_11_23_0 [ 1 ] = _rtP -> P_33
[ 1 ] ; _rtB -> B_11_24_0 [ 1 ] = _rtP -> P_34 [ 1 ] ; _rtB -> B_11_25_0 =
_rtP -> P_35 ; _rtB -> B_11_26_0 = _rtP -> P_36 ; _rtB -> B_11_27_0 [ 0 ] =
_rtP -> P_37 [ 0 ] ; _rtB -> B_11_28_0 [ 0 ] = _rtP -> P_38 [ 0 ] ; _rtB ->
B_11_27_0 [ 1 ] = _rtP -> P_37 [ 1 ] ; _rtB -> B_11_28_0 [ 1 ] = _rtP -> P_38
[ 1 ] ; _rtB -> B_11_27_0 [ 2 ] = _rtP -> P_37 [ 2 ] ; _rtB -> B_11_28_0 [ 2
] = _rtP -> P_38 [ 2 ] ; _rtB -> B_11_27_0 [ 3 ] = _rtP -> P_37 [ 3 ] ; _rtB
-> B_11_28_0 [ 3 ] = _rtP -> P_38 [ 3 ] ; _rtB -> B_11_29_0 [ 0 ] = _rtP ->
P_39 [ 0 ] ; _rtB -> B_11_29_0 [ 1 ] = _rtP -> P_39 [ 1 ] ; _rtB -> B_11_30_0
= _rtP -> P_40 ; _rtB -> B_11_31_0 = _rtP -> P_41 ; _rtB -> B_11_32_0 = _rtP
-> P_42 ; _rtB -> B_11_33_0 = _rtP -> P_43 ; memcpy ( & _rtB -> B_11_34_0 [ 0
] , & _rtP -> P_44 [ 0 ] , sizeof ( real_T ) << 3U ) ; for ( i = 0 ; i < 6 ;
i ++ ) { _rtB -> B_11_37_0 [ i ] = _rtP -> P_45 [ i ] ; _rtB -> B_11_41_0 [ i
] = _rtP -> P_46 [ i ] ; } _rtB -> B_11_43_0 = _rtP -> P_47 ; _rtB ->
B_11_62_0 = _rtP -> P_56 ; _rtB -> B_11_63_0 = _rtP -> P_57 ; _rtB ->
B_11_66_0 = _rtP -> P_58 ; _rtB -> B_8_0_0 = _rtP -> P_0 ; _rtB -> B_8_4_0 =
_rtP -> P_2 ; _rtB -> B_11_69_0 = _rtP -> P_59 ; _rtB -> B_11_70_0 = _rtP ->
P_60 ; _rtB -> B_10_0_0 = _rtP -> P_4 ; _rtB -> B_10_3_0 = _rtP -> P_5 ;
UNUSED_PARAMETER ( tid ) ; }
#define MDL_UPDATE
static void mdlUpdate ( SimStruct * S , int_T tid ) { int32_T isHit ;
B_NLMPC_Interface_R2018b_T * _rtB ; P_NLMPC_Interface_R2018b_T * _rtP ;
DW_NLMPC_Interface_R2018b_T * _rtDW ; _rtDW = ( ( DW_NLMPC_Interface_R2018b_T
* ) ssGetRootDWork ( S ) ) ; _rtP = ( ( P_NLMPC_Interface_R2018b_T * )
ssGetModelRtp ( S ) ) ; _rtB = ( ( B_NLMPC_Interface_R2018b_T * )
_ssGetModelBlockIO ( S ) ) ; { real_T * * uBuffer = ( real_T * * ) & _rtDW ->
TransportDelay_PWORK . TUbufferPtrs [ 0 ] ; real_T * * tBuffer = ( real_T * *
) & _rtDW -> TransportDelay_PWORK . TUbufferPtrs [ 1 ] ; real_T simTime =
ssGetT ( S ) ; _rtDW -> TransportDelay_IWORK . Head = ( ( _rtDW ->
TransportDelay_IWORK . Head < ( _rtDW -> TransportDelay_IWORK .
CircularBufSize - 1 ) ) ? ( _rtDW -> TransportDelay_IWORK . Head + 1 ) : 0 )
; if ( _rtDW -> TransportDelay_IWORK . Head == _rtDW -> TransportDelay_IWORK
. Tail ) { if ( ! NLMPC_Interface_R2018b_acc_rt_TDelayUpdateTailOrGrowBuf ( &
_rtDW -> TransportDelay_IWORK . CircularBufSize , & _rtDW ->
TransportDelay_IWORK . Tail , & _rtDW -> TransportDelay_IWORK . Head , &
_rtDW -> TransportDelay_IWORK . Last , simTime - _rtP -> P_27 , tBuffer ,
uBuffer , ( NULL ) , ( boolean_T ) 0 , false , & _rtDW ->
TransportDelay_IWORK . MaxNewBufSize ) ) { ssSetErrorStatus ( S ,
"tdelay memory allocation error" ) ; return ; } } ( * tBuffer ) [ _rtDW ->
TransportDelay_IWORK . Head ] = simTime ; ( * uBuffer ) [ _rtDW ->
TransportDelay_IWORK . Head ] = _rtB -> B_7_0_1 ; } isHit = ssIsSampleHit ( S
, 2 , 0 ) ; if ( isHit != 0 ) { _rtDW -> icLoad = 0U ; memcpy ( & _rtDW ->
mv_Delay_DSTATE [ 0 ] , & _rtB -> B_7_0_3 [ 0 ] , sizeof ( real_T ) << 3U ) ;
_rtDW -> icLoad_f = 0U ; memcpy ( & _rtDW -> x_Delay_DSTATE [ 0 ] , & _rtB ->
B_7_0_4 [ 0 ] , sizeof ( real_T ) << 5U ) ; _rtDW -> icLoad_g = 0U ; _rtDW ->
slack_delay_DSTATE = _rtB -> B_7_0_7 ; } UNUSED_PARAMETER ( tid ) ; }
#define MDL_UPDATE
static void mdlUpdateTID3 ( SimStruct * S , int_T tid ) { UNUSED_PARAMETER (
tid ) ; }
#define MDL_DERIVATIVES
static void mdlDerivatives ( SimStruct * S ) { B_NLMPC_Interface_R2018b_T *
_rtB ; P_NLMPC_Interface_R2018b_T * _rtP ; X_NLMPC_Interface_R2018b_T * _rtX
; XDot_NLMPC_Interface_R2018b_T * _rtXdot ; _rtXdot = ( (
XDot_NLMPC_Interface_R2018b_T * ) ssGetdX ( S ) ) ; _rtX = ( (
X_NLMPC_Interface_R2018b_T * ) ssGetContStates ( S ) ) ; _rtP = ( (
P_NLMPC_Interface_R2018b_T * ) ssGetModelRtp ( S ) ) ; _rtB = ( (
B_NLMPC_Interface_R2018b_T * ) _ssGetModelBlockIO ( S ) ) ; _rtXdot ->
DerivativeFilter_CSTATE [ 0 ] = 0.0 ; _rtXdot -> DerivativeFilter_CSTATE [ 0
] += _rtP -> P_49 [ 0 ] * _rtX -> DerivativeFilter_CSTATE [ 0 ] ; _rtXdot ->
DerivativeFilter_CSTATE [ 1 ] = 0.0 ; _rtXdot -> DerivativeFilter_CSTATE [ 0
] += _rtP -> P_49 [ 1 ] * _rtX -> DerivativeFilter_CSTATE [ 1 ] ; _rtXdot ->
DerivativeFilter_CSTATE [ 1 ] += _rtX -> DerivativeFilter_CSTATE [ 0 ] ;
_rtXdot -> DerivativeFilter_CSTATE [ 0 ] += _rtB -> B_11_7_0 ; _rtXdot ->
DerivativeFilter1_CSTATE [ 0 ] = 0.0 ; _rtXdot -> DerivativeFilter1_CSTATE [
0 ] += _rtP -> P_51 [ 0 ] * _rtX -> DerivativeFilter1_CSTATE [ 0 ] ; _rtXdot
-> DerivativeFilter1_CSTATE [ 1 ] = 0.0 ; _rtXdot -> DerivativeFilter1_CSTATE
[ 0 ] += _rtP -> P_51 [ 1 ] * _rtX -> DerivativeFilter1_CSTATE [ 1 ] ;
_rtXdot -> DerivativeFilter1_CSTATE [ 1 ] += _rtX -> DerivativeFilter1_CSTATE
[ 0 ] ; _rtXdot -> DerivativeFilter1_CSTATE [ 0 ] += _rtB -> B_11_3_0 ; }
static void mdlInitializeSizes ( SimStruct * S ) { ssSetChecksumVal ( S , 0 ,
25610317U ) ; ssSetChecksumVal ( S , 1 , 4100451010U ) ; ssSetChecksumVal ( S
, 2 , 3827995663U ) ; ssSetChecksumVal ( S , 3 , 762788475U ) ; { mxArray *
slVerStructMat = NULL ; mxArray * slStrMat = mxCreateString ( "simulink" ) ;
char slVerChar [ 10 ] ; int status = mexCallMATLAB ( 1 , & slVerStructMat , 1
, & slStrMat , "ver" ) ; if ( status == 0 ) { mxArray * slVerMat = mxGetField
( slVerStructMat , 0 , "Version" ) ; if ( slVerMat == NULL ) { status = 1 ; }
else { status = mxGetString ( slVerMat , slVerChar , 10 ) ; } }
mxDestroyArray ( slStrMat ) ; mxDestroyArray ( slVerStructMat ) ; if ( (
status == 1 ) || ( strcmp ( slVerChar , "9.2" ) != 0 ) ) { return ; } }
ssSetOptions ( S , SS_OPTION_EXCEPTION_FREE_CODE ) ; if ( ssGetSizeofDWork (
S ) != sizeof ( DW_NLMPC_Interface_R2018b_T ) ) { ssSetErrorStatus ( S ,
"Unexpected error: Internal DWork sizes do "
"not match for accelerator mex file." ) ; } if ( ssGetSizeofGlobalBlockIO ( S
) != sizeof ( B_NLMPC_Interface_R2018b_T ) ) { ssSetErrorStatus ( S ,
"Unexpected error: Internal BlockIO sizes do "
"not match for accelerator mex file." ) ; } { int ssSizeofParams ;
ssGetSizeofParams ( S , & ssSizeofParams ) ; if ( ssSizeofParams != sizeof (
P_NLMPC_Interface_R2018b_T ) ) { static char msg [ 256 ] ; sprintf ( msg ,
"Unexpected error: Internal Parameters sizes do "
"not match for accelerator mex file." ) ; } } _ssSetModelRtp ( S , ( real_T *
) & NLMPC_Interface_R2018b_rtDefaultP ) ; rt_InitInfAndNaN ( sizeof ( real_T
) ) ; ( ( P_NLMPC_Interface_R2018b_T * ) ssGetModelRtp ( S ) ) -> P_7 = rtInf
; ( ( P_NLMPC_Interface_R2018b_T * ) ssGetModelRtp ( S ) ) -> P_11 = rtInf ;
( ( P_NLMPC_Interface_R2018b_T * ) ssGetModelRtp ( S ) ) -> P_13 = rtInf ; (
( P_NLMPC_Interface_R2018b_T * ) ssGetModelRtp ( S ) ) -> P_17 = rtInf ; ( (
P_NLMPC_Interface_R2018b_T * ) ssGetModelRtp ( S ) ) -> P_66 = rtInf ; }
static void mdlInitializeSampleTimes ( SimStruct * S ) { { SimStruct * childS
; SysOutputFcn * callSysFcns ; childS = ssGetSFunction ( S , 0 ) ;
callSysFcns = ssGetCallSystemOutputFcnList ( childS ) ; callSysFcns [ 3 + 0 ]
= ( SysOutputFcn ) ( NULL ) ; childS = ssGetSFunction ( S , 1 ) ; callSysFcns
= ssGetCallSystemOutputFcnList ( childS ) ; callSysFcns [ 3 + 0 ] = (
SysOutputFcn ) ( NULL ) ; childS = ssGetSFunction ( S , 2 ) ; callSysFcns =
ssGetCallSystemOutputFcnList ( childS ) ; callSysFcns [ 3 + 0 ] = (
SysOutputFcn ) ( NULL ) ; childS = ssGetSFunction ( S , 3 ) ; callSysFcns =
ssGetCallSystemOutputFcnList ( childS ) ; callSysFcns [ 3 + 0 ] = (
SysOutputFcn ) ( NULL ) ; } slAccRegPrmChangeFcn ( S , mdlOutputsTID3 ) ; }
static void mdlTerminate ( SimStruct * S ) { }
#include "simulink.c"
