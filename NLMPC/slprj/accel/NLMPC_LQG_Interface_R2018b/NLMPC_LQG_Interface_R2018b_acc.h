#include "__cf_NLMPC_LQG_Interface_R2018b.h"
#ifndef RTW_HEADER_NLMPC_LQG_Interface_R2018b_acc_h_
#define RTW_HEADER_NLMPC_LQG_Interface_R2018b_acc_h_
#include <stddef.h>
#include <float.h>
#include <string.h>
#ifndef NLMPC_LQG_Interface_R2018b_acc_COMMON_INCLUDES_
#define NLMPC_LQG_Interface_R2018b_acc_COMMON_INCLUDES_
#include <stdlib.h>
#define S_FUNCTION_NAME simulink_only_sfcn 
#define S_FUNCTION_LEVEL 2
#define RTW_GENERATED_S_FUNCTION
#include "sl_AsyncioQueue/AsyncioQueueCAPI.h"
#include "simtarget/slSimTgtSigstreamRTW.h"
#include "simtarget/slSimTgtSlioCoreRTW.h"
#include "simtarget/slSimTgtSlioClientsRTW.h"
#include "simtarget/slSimTgtSlioSdiRTW.h"
#include "rtwtypes.h"
#include "simstruc.h"
#include "fixedpoint.h"
#endif
#include "NLMPC_LQG_Interface_R2018b_acc_types.h"
#include "multiword_types.h"
#include "mwmathutil.h"
#include "rtGetInf.h"
#include "rt_defines.h"
#include "rt_nonfinite.h"
typedef struct { real_T B_12_0_0 [ 2 ] ; real_T B_12_1_0 ; real_T B_12_2_0 ;
real_T B_12_4_0 ; real_T B_12_5_0 ; real_T B_12_6_0 ; real_T B_12_8_0 ;
real_T B_12_9_0 ; real_T B_12_10_0 ; real_T B_12_17_0 [ 4 ] ; real_T
B_12_18_0 ; real_T B_12_20_0 ; real_T B_12_23_0 ; real_T B_12_24_0 ; real_T
B_12_25_0 ; real_T B_12_26_0 ; real_T B_12_27_0 ; real_T B_12_28_0 ; real_T
B_12_29_0 [ 2 ] ; real_T B_12_30_0 [ 2 ] ; real_T B_12_31_0 ; real_T
B_12_32_0 ; real_T B_12_33_0 [ 4 ] ; real_T B_12_34_0 [ 4 ] ; real_T
B_12_35_0 [ 2 ] ; real_T B_12_36_0 ; real_T B_12_37_0 ; real_T B_12_38_0 ;
real_T B_12_39_0 ; real_T B_12_40_0 [ 8 ] ; real_T B_12_41_0 [ 8 ] ; real_T
B_12_43_0 [ 6 ] ; real_T B_12_44_0 [ 6 ] ; real_T B_12_45_0 [ 32 ] ; real_T
B_12_47_0 [ 6 ] ; real_T B_12_48_0 [ 24 ] ; real_T B_12_49_0 ; real_T
B_12_50_0 ; real_T B_12_53_0 ; real_T B_12_54_0 ; real_T B_12_58_0 ; real_T
B_12_59_0 ; real_T B_12_65_0 [ 16 ] ; real_T B_12_69_0 ; real_T B_12_70_0 ;
real_T B_12_71_0 ; real_T B_12_73_0 ; real_T B_12_74_0 ; real_T B_12_76_0 ;
real_T B_12_77_0 ; real_T B_12_81_0 ; real_T B_12_84_0 ; real_T B_12_86_0 ;
real_T B_12_88_0 ; real_T B_11_0_0 ; real_T B_11_3_0 ; real_T B_10_0_0 ;
real_T B_9_0_0 ; real_T B_9_4_0 ; real_T B_8_0_1 ; real_T B_8_0_2 ; real_T
B_8_0_3 [ 8 ] ; real_T B_8_0_4 [ 32 ] ; real_T B_8_0_5 [ 16 ] ; real_T
B_8_0_6 ; real_T B_8_0_7 ; real_T B_7_0_0 [ 4 ] ; real_T B_7_1_0 [ 16 ] ;
real_T B_6_0_1 [ 4 ] ; real_T B_6_0_2 [ 16 ] ; real_T B_5_0_0 [ 4 ] ; real_T
B_4_0_0 [ 4 ] ; real_T B_4_1_0 [ 16 ] ; real_T B_3_0_1 [ 4 ] ; real_T B_3_0_2
[ 16 ] ; real_T B_2_0_0 [ 4 ] ; real_T B_2_1_0 [ 16 ] ; real_T B_1_0_1 [ 4 ]
; real_T B_1_0_2 [ 16 ] ; int32_T B_12_1_1 ; int32_T B_12_2_1 ; int32_T
B_12_82_0 ; boolean_T B_12_11_0 ; boolean_T B_5_2_0 ; boolean_T B_3_0_3 ;
boolean_T B_1_0_3 ; } B_NLMPC_LQG_Interface_R2018b_T ; typedef struct {
real_T mv_Delay_DSTATE [ 8 ] ; real_T x_Delay_DSTATE [ 32 ] ; real_T
slack_delay_DSTATE ; real_T P [ 16 ] ; real_T x [ 4 ] ; struct { real_T
modelTStart ; } TransportDelay_RWORK ; void * EncoderInput1_PWORK ; void *
EncoderInput_PWORK ; struct { void * TUbufferPtrs [ 2 ] ; }
TransportDelay_PWORK ; void * ActionVariableExecutionTime_PWORK [ 2 ] ;
struct { void * AQHandles ; void * SlioLTF ; }
HiddenToAsyncQueue_InsertedFor_ExtendedKalmanFilter_at_outport_0_PWORK ;
struct { void * AQHandles ; void * SlioLTF ; }
HiddenToAsyncQueue_InsertedFor_NonlinearMPCController_at_outport_0_PWORK ;
void * StateVariables_PWORK [ 4 ] ; void * ToWorkspace_1_PWORK ; struct {
void * AQHandles ; void * SlioLTF ; }
HiddenToAsyncQueue_InsertedFor_ZeroOrderHold_at_outport_0_PWORK ; struct {
void * AQHandles ; void * SlioLTF ; }
HiddenToAsyncQueue_InsertedFor_ZeroOrderHold1_at_outport_0_PWORK ; struct {
void * AQHandles ; void * SlioLTF ; }
HiddenToAsyncQueue_InsertedFor_ZeroOrderHold2_at_outport_0_PWORK ; void *
DataStoreMemoryP_PWORK ; void * DataStoreMemoryx_PWORK ; void *
AnalogOutput_PWORK ; void * Scope_PWORK [ 3 ] ; void * VCommandV_PWORK ;
int32_T dsmIdx ; int32_T dsmIdx_f ; int32_T CartPositionWatchdog_sysIdxToRun
; int32_T Holdsstatesonceenabled_sysIdxToRun ; int32_T
CartPendulumAngleWatchdog_sysIdxToRun ; int32_T NLMPC_sysIdxToRun ; int32_T
Predict_sysIdxToRun ; int32_T Predict_sysIdxToRun_c ; int32_T
Output_sysIdxToRun ; int32_T Correct2_sysIdxToRun ; int32_T
Correct_sysIdxToRun ; int32_T Correct1_sysIdxToRun ; int32_T
Correct_sysIdxToRun_f ; int32_T
TmpAtomicSubsysAtThreshold05Inport1_sysIdxToRun ; struct { int_T Tail ; int_T
Head ; int_T Last ; int_T CircularBufSize ; int_T MaxNewBufSize ; }
TransportDelay_IWORK ; int8_T CartPositionWatchdog_SubsysRanBC ; int8_T
Holdsstatesonceenabled_SubsysRanBC ; int8_T
CartPendulumAngleWatchdog_SubsysRanBC ; int8_T Correct2_SubsysRanBC ; int8_T
Correct1_SubsysRanBC ; uint8_T icLoad ; uint8_T icLoad_f ; uint8_T icLoad_g ;
boolean_T Correct2_MODE ; boolean_T Correct1_MODE ; char_T pad_Correct1_MODE
[ 2 ] ; } DW_NLMPC_LQG_Interface_R2018b_T ; typedef struct { real_T
DerivativeFilter_CSTATE [ 2 ] ; real_T DerivativeFilter1_CSTATE [ 2 ] ; }
X_NLMPC_LQG_Interface_R2018b_T ; typedef struct { real_T
DerivativeFilter_CSTATE [ 2 ] ; real_T DerivativeFilter1_CSTATE [ 2 ] ; }
XDot_NLMPC_LQG_Interface_R2018b_T ; typedef struct { boolean_T
DerivativeFilter_CSTATE [ 2 ] ; boolean_T DerivativeFilter1_CSTATE [ 2 ] ; }
XDis_NLMPC_LQG_Interface_R2018b_T ; struct P_NLMPC_LQG_Interface_R2018b_T_ {
real_T P_0 [ 4 ] ; real_T P_1 ; real_T P_2 ; real_T P_3 ; real_T P_4 ; real_T
P_5 ; real_T P_6 ; real_T P_7 ; real_T P_8 ; real_T P_9 [ 2 ] ; real_T P_10 [
2 ] ; real_T P_11 ; real_T P_12 [ 2 ] ; real_T P_13 ; real_T P_14 [ 2 ] ;
real_T P_15 ; real_T P_16 [ 2 ] ; real_T P_17 ; real_T P_18 [ 2 ] ; real_T
P_19 ; real_T P_20 [ 2 ] ; real_T P_21 ; real_T P_22 ; real_T P_23 ; real_T
P_24 ; real_T P_25 ; real_T P_26 ; real_T P_27 ; real_T P_28 ; real_T P_29 ;
real_T P_30 [ 4 ] ; real_T P_31 ; real_T P_32 ; real_T P_33 ; real_T P_34 ;
real_T P_35 ; real_T P_36 ; real_T P_37 ; real_T P_38 ; real_T P_39 [ 2 ] ;
real_T P_40 [ 2 ] ; real_T P_41 ; real_T P_42 ; real_T P_43 [ 4 ] ; real_T
P_44 [ 4 ] ; real_T P_45 [ 2 ] ; real_T P_46 ; real_T P_47 ; real_T P_48 ;
real_T P_49 ; real_T P_50 [ 8 ] ; real_T P_51 [ 6 ] ; real_T P_52 [ 6 ] ;
real_T P_53 ; real_T P_54 ; real_T P_55 [ 2 ] ; real_T P_56 [ 2 ] ; real_T
P_57 [ 2 ] ; real_T P_58 [ 2 ] ; real_T P_59 [ 16 ] ; real_T P_60 [ 16 ] ;
real_T P_61 [ 4 ] ; real_T P_62 ; real_T P_63 ; real_T P_64 ; real_T P_65 ;
real_T P_66 ; real_T P_67 ; real_T P_68 ; real_T P_69 ; real_T P_70 ; real_T
P_71 [ 2 ] ; real_T P_72 ; real_T P_73 [ 2 ] ; real_T P_74 ; real_T P_75 [ 2
] ; real_T P_77 [ 2 ] ; real_T P_78 ; real_T P_79 ; real_T P_80 ; real_T P_81
; real_T P_82 [ 2 ] ; int32_T P_83 ; char_T pad_P_83 [ 4 ] ; real_T P_84 [ 2
] ; int32_T P_85 ; char_T pad_P_85 [ 4 ] ; real_T P_86 [ 2 ] ; int32_T P_87 ;
char_T pad_P_87 [ 4 ] ; real_T P_88 [ 2 ] ; int32_T P_89 ; char_T pad_P_89 [
4 ] ; real_T P_90 [ 2 ] ; int32_T P_91 ; uint32_T P_92 ; uint32_T P_93 ;
uint32_T P_94 ; boolean_T P_95 ; boolean_T P_96 ; boolean_T P_97 ; char_T
pad_P_97 [ 5 ] ; } ; extern P_NLMPC_LQG_Interface_R2018b_T
NLMPC_LQG_Interface_R2018b_rtDefaultP ;
#endif
