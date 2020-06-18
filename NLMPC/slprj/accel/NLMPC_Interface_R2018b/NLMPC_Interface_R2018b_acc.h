#include "__cf_NLMPC_Interface_R2018b.h"
#ifndef RTW_HEADER_NLMPC_Interface_R2018b_acc_h_
#define RTW_HEADER_NLMPC_Interface_R2018b_acc_h_
#include <stddef.h>
#include <float.h>
#include <string.h>
#ifndef NLMPC_Interface_R2018b_acc_COMMON_INCLUDES_
#define NLMPC_Interface_R2018b_acc_COMMON_INCLUDES_
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
#include "NLMPC_Interface_R2018b_acc_types.h"
#include "multiword_types.h"
#include "mwmathutil.h"
#include "rtGetInf.h"
#include "rt_defines.h"
#include "rt_nonfinite.h"
typedef struct { real_T B_11_0_0 ; real_T B_11_1_0 ; real_T B_11_3_0 ; real_T
B_11_4_0 ; real_T B_11_5_0 ; real_T B_11_7_0 ; real_T B_11_8_0 ; real_T
B_11_9_0 ; real_T B_11_16_0 [ 2 ] ; real_T B_11_17_0 ; real_T B_11_18_0 ;
real_T B_11_19_0 ; real_T B_11_20_0 ; real_T B_11_21_0 ; real_T B_11_22_0 ;
real_T B_11_23_0 [ 2 ] ; real_T B_11_24_0 [ 2 ] ; real_T B_11_25_0 ; real_T
B_11_26_0 ; real_T B_11_27_0 [ 4 ] ; real_T B_11_28_0 [ 4 ] ; real_T
B_11_29_0 [ 2 ] ; real_T B_11_30_0 ; real_T B_11_31_0 ; real_T B_11_32_0 ;
real_T B_11_33_0 ; real_T B_11_34_0 [ 8 ] ; real_T B_11_35_0 [ 8 ] ; real_T
B_11_37_0 [ 6 ] ; real_T B_11_38_0 [ 6 ] ; real_T B_11_39_0 [ 32 ] ; real_T
B_11_41_0 [ 6 ] ; real_T B_11_42_0 [ 24 ] ; real_T B_11_43_0 ; real_T
B_11_44_0 ; real_T B_11_46_0 ; real_T B_11_50_0 ; real_T B_11_51_0 ; real_T
B_11_54_0 ; real_T B_11_58_0 [ 16 ] ; real_T B_11_62_0 ; real_T B_11_63_0 ;
real_T B_11_64_0 ; real_T B_11_66_0 ; real_T B_11_67_0 ; real_T B_11_69_0 ;
real_T B_11_70_0 ; real_T B_11_74_0 ; real_T B_11_77_0 ; real_T B_11_79_0 ;
real_T B_11_81_0 ; real_T B_10_0_0 ; real_T B_10_3_0 ; real_T B_9_0_0 ;
real_T B_8_0_0 ; real_T B_8_4_0 ; real_T B_7_0_1 ; real_T B_7_0_2 ; real_T
B_7_0_3 [ 8 ] ; real_T B_7_0_4 [ 32 ] ; real_T B_7_0_5 [ 16 ] ; real_T
B_7_0_6 ; real_T B_7_0_7 ; real_T B_6_0_0 [ 4 ] ; real_T B_6_1_0 [ 16 ] ;
real_T B_5_0_1 [ 4 ] ; real_T B_5_0_2 [ 16 ] ; real_T B_4_0_0 [ 4 ] ; real_T
B_3_0_0 [ 4 ] ; real_T B_3_1_0 [ 16 ] ; real_T B_2_0_1 [ 4 ] ; real_T B_2_0_2
[ 16 ] ; real_T B_1_0_0 [ 4 ] ; real_T B_1_1_0 [ 16 ] ; real_T B_0_0_1 [ 4 ]
; real_T B_0_0_2 [ 16 ] ; int32_T B_11_0_1 ; int32_T B_11_1_1 ; int32_T
B_11_75_0 ; boolean_T B_11_10_0 ; boolean_T B_4_2_0 ; boolean_T B_2_0_3 ;
boolean_T B_0_0_3 ; } B_NLMPC_Interface_R2018b_T ; typedef struct { real_T
mv_Delay_DSTATE [ 8 ] ; real_T x_Delay_DSTATE [ 32 ] ; real_T
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
Correct_sysIdxToRun_f ; struct { int_T Tail ; int_T Head ; int_T Last ; int_T
CircularBufSize ; int_T MaxNewBufSize ; } TransportDelay_IWORK ; int8_T
CartPositionWatchdog_SubsysRanBC ; int8_T Holdsstatesonceenabled_SubsysRanBC
; int8_T CartPendulumAngleWatchdog_SubsysRanBC ; int8_T Correct2_SubsysRanBC
; int8_T Correct1_SubsysRanBC ; uint8_T icLoad ; uint8_T icLoad_f ; uint8_T
icLoad_g ; boolean_T Correct2_MODE ; boolean_T Correct1_MODE ; char_T
pad_Correct1_MODE [ 6 ] ; } DW_NLMPC_Interface_R2018b_T ; typedef struct {
real_T DerivativeFilter_CSTATE [ 2 ] ; real_T DerivativeFilter1_CSTATE [ 2 ]
; } X_NLMPC_Interface_R2018b_T ; typedef struct { real_T
DerivativeFilter_CSTATE [ 2 ] ; real_T DerivativeFilter1_CSTATE [ 2 ] ; }
XDot_NLMPC_Interface_R2018b_T ; typedef struct { boolean_T
DerivativeFilter_CSTATE [ 2 ] ; boolean_T DerivativeFilter1_CSTATE [ 2 ] ; }
XDis_NLMPC_Interface_R2018b_T ; struct P_NLMPC_Interface_R2018b_T_ { real_T
P_0 ; real_T P_1 ; real_T P_2 ; real_T P_3 ; real_T P_4 ; real_T P_5 ; real_T
P_6 [ 2 ] ; real_T P_7 ; real_T P_8 [ 2 ] ; real_T P_9 ; real_T P_10 [ 2 ] ;
real_T P_11 ; real_T P_12 [ 2 ] ; real_T P_13 ; real_T P_14 [ 2 ] ; real_T
P_15 ; real_T P_16 [ 2 ] ; real_T P_17 ; real_T P_18 ; real_T P_19 ; real_T
P_20 ; real_T P_21 ; real_T P_22 ; real_T P_23 ; real_T P_24 ; real_T P_25 ;
real_T P_26 [ 2 ] ; real_T P_27 ; real_T P_28 ; real_T P_29 ; real_T P_30 ;
real_T P_31 ; real_T P_32 ; real_T P_33 [ 2 ] ; real_T P_34 [ 2 ] ; real_T
P_35 ; real_T P_36 ; real_T P_37 [ 4 ] ; real_T P_38 [ 4 ] ; real_T P_39 [ 2
] ; real_T P_40 ; real_T P_41 ; real_T P_42 ; real_T P_43 ; real_T P_44 [ 8 ]
; real_T P_45 [ 6 ] ; real_T P_46 [ 6 ] ; real_T P_47 ; real_T P_48 ; real_T
P_49 [ 2 ] ; real_T P_50 [ 2 ] ; real_T P_51 [ 2 ] ; real_T P_52 [ 2 ] ;
real_T P_53 [ 16 ] ; real_T P_54 [ 16 ] ; real_T P_55 [ 4 ] ; real_T P_56 ;
real_T P_57 ; real_T P_58 ; real_T P_59 ; real_T P_60 ; real_T P_61 ; real_T
P_62 ; real_T P_63 ; real_T P_64 ; real_T P_65 [ 2 ] ; real_T P_66 ; real_T
P_67 [ 2 ] ; real_T P_68 ; real_T P_69 [ 2 ] ; real_T P_71 [ 2 ] ; real_T
P_72 ; real_T P_73 ; real_T P_74 ; real_T P_75 ; real_T P_76 [ 2 ] ; int32_T
P_77 ; char_T pad_P_77 [ 4 ] ; real_T P_78 [ 2 ] ; int32_T P_79 ; char_T
pad_P_79 [ 4 ] ; real_T P_80 [ 2 ] ; int32_T P_81 ; char_T pad_P_81 [ 4 ] ;
real_T P_82 [ 2 ] ; int32_T P_83 ; char_T pad_P_83 [ 4 ] ; real_T P_84 [ 2 ]
; int32_T P_85 ; uint32_T P_86 ; uint32_T P_87 ; uint32_T P_88 ; boolean_T
P_89 ; boolean_T P_90 ; boolean_T P_91 ; char_T pad_P_91 [ 5 ] ; } ; extern
P_NLMPC_Interface_R2018b_T NLMPC_Interface_R2018b_rtDefaultP ;
#endif
