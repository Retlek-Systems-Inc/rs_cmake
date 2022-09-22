cmake_minimum_required(VERSION 3.15)

# User is responsible to one mandatory option:
# FREERTOS_PORT
#
# User is also responsible for adding a freertos_config target - typcially an INTERFACE library
#
# User can choose which heap implementation to use (either the implementations
# included with FreeRTOS [1..5] or a custom implementation ) by providing the
# option FREERTOS_HEAP. If the option is not set, the cmake will default to
# using heap_4.c.

# FreeRTOS::Config target - typically INTERFACE - defines the path to FreeRTOSConfig.h and optionally other freertos based config files
if(NOT TARGET freertos_config )
    message(FATAL_ERROR " freertos_config target not specified.  Please specify a cmake target that defines the include directory for FreeRTOSConfig.h:\n"
        "  add_library(freertos_config INTERFACE)\n"
        "  add_library(FreeRTOS::Config ALIAS freertos_config)\n"
        "  target_include_directories(freertos_config SYSTEM\n"
        "    INTERFACE\n"
        "      include) # The config file directory\n"
        "  target_compile_definitions(freertos_config\n"
        "    PUBLIC\n"
        "    projCOVERAGE_TEST=0)\n")
endif()

# Heap number or absolute path to custom heap implementation provided by user
set(FREERTOS_HEAP "4" CACHE STRING "FreeRTOS heap model number. 1 .. 5. Or absolute path to custom heap source file")

# FreeRTOS port option
set(FREERTOS_PORT "" CACHE STRING "FreeRTOS port name")

if(NOT FREERTOS_PORT)
    message(FATAL_ERROR " FREERTOS_PORT is not set. Please specify it from top-level CMake file (example):\n"
        "  set(FREERTOS_PORT GCC_ARM_CM4F CACHE STRING \"\")\n"
        " or from CMake command line option:\n"
        "  -DFREERTOS_PORT=GCC_ARM_CM4F\n"
        " \n"
        " Available port options:\n"
        " A_CUSTOM_PORT                    - Compiler: UserDefined    Target: User Defined\n"
        " BCC_16BIT_DOS_FLSH186            - Compiller: BCC           Target: 16 bit DOS Flsh186\n"
        " BCC_16BIT_DOS_PC                 - Compiller: BCC           Target: 16 bit DOS PC\n"
        " CCS_ARM_CM3                      - Compiller: CCS           Target: ARM Cortex-M3\n"
        " CCS_ARM_CM4F                     - Compiller: CCS           Target: ARM Cortex-M4 with FPU\n"
        " CCS_ARM_CR4                      - Compiller: CCS           Target: ARM Cortex-R4\n"
        " CCS_MSP430X                      - Compiller: CCS           Target: MSP430X\n"
        " CODEWARRIOR_COLDFIRE_V1          - Compiller: CoreWarrior   Target: ColdFire V1\n"
        " CODEWARRIOR_COLDFIRE_V2          - Compiller: CoreWarrior   Target: ColdFire V2\n"
        " CODEWARRIOR_HCS12                - Compiller: CoreWarrior   Target: HCS12\n"
        " GCC_ARM_CA9                      - Compiller: GCC           Target: ARM Cortex-A9\n"
        " GCC_ARM_CA53_64_BIT              - Compiller: GCC           Target: ARM Cortex-A53 64 bit\n"
        " GCC_ARM_CA53_64_BIT_SRE          - Compiller: GCC           Target: ARM Cortex-A53 64 bit SRE\n"
        " GCC_ARM_CM0                      - Compiller: GCC           Target: ARM Cortex-M0\n"
        " GCC_ARM_CM3                      - Compiller: GCC           Target: ARM Cortex-M3\n"
        " GCC_ARM_CM3_MPU                  - Compiller: GCC           Target: ARM Cortex-M3 with MPU\n"
        " GCC_ARM_CM4_MPU                  - Compiller: GCC           Target: ARM Cortex-M4 with MPU\n"
        " GCC_ARM_CM4F                     - Compiller: GCC           Target: ARM Cortex-M4 with FPU\n"
        " GCC_ARM_CM7                      - Compiller: GCC           Target: ARM Cortex-M7\n"
        " GCC_ARM_CM23_NONSECURE           - Compiller: GCC           Target: ARM Cortex-M23 non-secure\n"
        " GCC_ARM_CM23_SECURE              - Compiller: GCC           Target: ARM Cortex-M23 secure\n"
        " GCC_ARM_CM23_NTZ_NONSECURE       - Compiller: GCC           Target: ARM Cortex-M23 non-trustzone non-secure\n"
        " GCC_ARM_CM33_NONSECURE           - Compiller: GCC           Target: ARM Cortex-M33 non-secure\n"
        " GCC_ARM_CM33_SECURE              - Compiller: GCC           Target: ARM Cortex-M33 secure\n"
        " GCC_ARM_CM33_NTZ_NONSECURE       - Compiller: GCC           Target: ARM Cortex-M33 non-trustzone non-secure\n"
        " GCC_ARM_CR5                      - Compiller: GCC           Target: ARM Cortex-R5\n"
        " GCC_ARM_CRX_NOGIC                - Compiller: GCC           Target: ARM Cortex-Rx no GIC\n"
        " GCC_ARM7_AT91FR40008             - Compiller: GCC           Target: ARM7 Atmel AT91R40008\n"
        " GCC_ARM7_AT91SAM7S               - Compiller: GCC           Target: ARM7 Atmel AT91SAM7S\n"
        " GCC_ARM7_LPC2000                 - Compiller: GCC           Target: ARM7 LPC2000\n"
        " GCC_ARM7_LPC23XX                 - Compiller: GCC           Target: ARM7 LPC23xx\n"
        " GCC_ATMEGA323                    - Compiller: GCC           Target: ATMega323\n"
        " GCC_AVR32_UC3                    - Compiller: GCC           Target: AVR32 UC3\n"
        " GCC_COLDFIRE_V2                  - Compiller: GCC           Target: ColdFire V2\n"
        " GCC_CORTUS_APS3                  - Compiller: GCC           Target: CORTUS APS3\n"
        " GCC_H8S2329                      - Compiller: GCC           Target: H8S2329\n"
        " GCC_HCS12                        - Compiller: GCC           Target: HCS12\n"
        " GCC_IA32_FLAT                    - Compiller: GCC           Target: IA32 flat\n"
        " GCC_MICROBLAZE                   - Compiller: GCC           Target: MicroBlaze\n"
        " GCC_MICROBLAZE_V8                - Compiller: GCC           Target: MicroBlaze V8\n"
        " GCC_MICROBLAZE_V9                - Compiller: GCC           Target: MicroBlaze V9\n"
        " GCC_MSP430F449                   - Compiller: GCC           Target: MSP430F449\n"
        " GCC_NIOSII                       - Compiller: GCC           Target: NiosII\n"
        " GCC_PPC405_XILINX                - Compiller: GCC           Target: Xilinx PPC405\n"
        " GCC_PPC440_XILINX                - Compiller: GCC           Target: Xilinx PPC440\n"
        " GCC_RISC_V                       - Compiller: GCC           Target: RISC-V\n"
        " GCC_RISC_V_PULPINO_VEGA_RV32M1RM - Compiller: GCC           Target: RISC-V Pulpino Vega RV32M1RM\n"
        " GCC_RL78                         - Compiller: GCC           Target: Renesas RL78\n"
        " GCC_RX100                        - Compiller: GCC           Target: Renesas RX100\n"
        " GCC_RX200                        - Compiller: GCC           Target: Renesas RX200\n"
        " GCC_RX600                        - Compiller: GCC           Target: Renesas RX600\n"
        " GCC_RX600_V2                     - Compiller: GCC           Target: Renesas RX600 v2\n"
        " GCC_RX700_V3_DPFPU               - Compiller: GCC           Target: Renesas RX700 v3 with DPFPU\n"
        " GCC_STR75X                       - Compiller: GCC           Target: STR75x\n"
        " GCC_TRICORE_1782                 - Compiller: GCC           Target: TriCore 1782\n"
        " GCC_ARC_EM_HS                    - Compiller: GCC           Target: DesignWare ARC EM HS\n"
        " GCC_ARC_V1                       - Compiller: GCC           Target: DesignWare ARC v1\n"
        " GCC_ARM_CM33_TFM                 - Compiller: GCC           Target: ARM Cortex-M33 trusted firmware\n"
        " GCC_ATMEGA                       - Compiller: GCC           Target: ATmega\n"
        " GCC_POSIX                        - Compiller: GCC           Target: Posix\n"
        " GCC_RP2040                       - Compiller: GCC           Target: RP2040 ARM Cortex-M0+\n"
        " GCC_XTENSA_ESP32                 - Compiller: GCC           Target: Xtensa ESP32\n"
        " GCC_AVRDX                        - Compiller: GCC           Target: AVRDx\n"
        " GCC_AVR_MEGA0                    - Compiller: GCC           Target: AVR Mega0\n"
        " IAR_78K0K                        - Compiller: IAR           Target: Renesas 78K0K\n"
        " IAR_ARM_CA5_NOGIC                - Compiller: IAR           Target: ARM Cortex-A5 no GIC\n"
        " IAR_ARM_CA9                      - Compiller: IAR           Target: ARM Cortex-A9\n"
        " IAR_ARM_CM0                      - Compiller: IAR           Target: ARM Cortex-M0\n"
        " IAR_ARM_CM3                      - Compiller: IAR           Target: ARM Cortex-M3\n"
        " IAR_ARM_CM4F                     - Compiller: IAR           Target: ARM Cortex-M4 with FPU\n"
        " IAR_ARM_CM4F_MPU                 - Compiller: IAR           Target: ARM Cortex-M4 with FPU and MPU\n"
        " IAR_ARM_CM7                      - Compiller: IAR           Target: ARM Cortex-M7\n"
        " IAR_ARM_CM23_NONSECURE           - Compiller: IAR           Target: ARM Cortex-M23 non-secure\n"
        " IAR_ARM_CM23_SECURE              - Compiller: IAR           Target: ARM Cortex-M23 secure\n"
        " IAR_ARM_CM23_NTZ_NONSECURE       - Compiller: IAR           Target: ARM Cortex-M23 non-trustzone non-secure\n"
        " IAR_ARM_CM33_NONSECURE           - Compiller: IAR           Target: ARM Cortex-M33 non-secure\n"
        " IAR_ARM_CM33_SECURE              - Compiller: IAR           Target: ARM Cortex-M33 secure\n"
        " IAR_ARM_CM33_NTZ_NONSECURE       - Compiller: IAR           Target: ARM Cortex-M33 non-trustzone non-secure\n"
        " IAR_ARM_CRX_NOGIC                - Compiller: IAR           Target: ARM Cortex-Rx no GIC\n"
        " IAR_ATMEGA323                    - Compiller: IAR           Target: ATMega323\n"
        " IAR_ATMEL_SAM7S64                - Compiller: IAR           Target: Atmel SAM7S64\n"
        " IAR_ATMEL_SAM9XE                 - Compiller: IAR           Target: Atmel SAM9XE\n"
        " IAR_AVR_AVRDX                    - Compiller: IAR           Target: AVRDx\n"
        " IAR_AVR_MEGA0                    - Compiller: IAR           Target: AVR Mega0\n"
        " IAR_AVR32_UC3                    - Compiller: IAR           Target: AVR32 UC3\n"
        " IAR_LPC2000                      - Compiller: IAR           Target: LPC2000\n"
        " IAR_MSP430                       - Compiller: IAR           Target: MSP430\n"
        " IAR_MSP430X                      - Compiller: IAR           Target: MSP430X\n"
        " IAR_RISC_V                       - Compiller: IAR           Target: RISC-V\n"
        " IAR_RL78                         - Compiller: IAR           Target: Renesas RL78\n"
        " IAR_RX100                        - Compiller: IAR           Target: Renesas RX100\n"
        " IAR_RX600                        - Compiller: IAR           Target: Renesas RX600\n"
        " IAR_RX700_V3_DPFPU               - Compiller: IAR           Target: Renesas RX700 v3 with DPFPU\n"
        " IAR_RX_V2                        - Compiller: IAR           Target: Renesas RX v2\n"
        " IAR_STR71X                       - Compiller: IAR           Target: STR71x\n"
        " IAR_STR75X                       - Compiller: IAR           Target: STR75x\n"
        " IAR_STR91X                       - Compiller: IAR           Target: STR91x\n"
        " IAR_V850ES_FX3                   - Compiller: IAR           Target: Renesas V850ES/Fx3\n"
        " IAR_V850ES_HX3                   - Compiller: IAR           Target: Renesas V850ES/Hx3\n"
        " MIKROC_ARM_CM4F                  - Compiller: MikroC        Target: ARM Cortex-M4 with FPU\n"
        " MPLAB_PIC18F                     - Compiller: MPLAB         Target: PIC18F\n"
        " MPLAB_PIC24                      - Compiller: MPLAB         Target: PIC24\n"
        " MPLAB_PIC32MEC14XX               - Compiller: MPLAB         Target: PIC32MEC14xx\n"
        " MPLAB_PIC32MX                    - Compiller: MPLAB         Target: PIC32MX\n"
        " MPLAB_PIC32MZ                    - Compiller: MPLAB         Target: PIC32MZ\n"
        " MSVC_MINGW                       - Compiller: MSVC or MinGW Target: x86\n"
        " OWATCOM_16BIT_DOS_FLSH186        - Compiller: Open Watcom   Target: 16 bit DOS Flsh186\n"
        " OWATCOM_16BIT_DOS_PC             - Compiller: Open Watcom   Target: 16 bit DOS PC\n"
        " PARADIGM_TERN_EE_LARGE           - Compiller: Paradigm      Target: Tern EE large\n"
        " PARADIGM_TERN_EE_SMALL           - Compiller: Paradigm      Target: Tern EE small\n"
        " RENESAS_RX100                    - Compiller: Renesas       Target: RX100\n"
        " RENESAS_RX200                    - Compiller: Renesas       Target: RX200\n"
        " RENESAS_RX600                    - Compiller: Renesas       Target: RX600\n"
        " RENESAS_RX600_V2                 - Compiller: Renesas       Target: RX600 v2\n"
        " RENESAS_RX700_V3_DPFPU           - Compiller: Renesas       Target: RX700 v3 with DPFPU\n"
        " RENESAS_SH2A_FPU                 - Compiller: Renesas       Target: SH2A with FPU\n"
        " ROWLEY_MSP430F449                - Compiller: Rowley        Target: MSP430F449\n"
        " RVDS_ARM_CA9                     - Compiller: RVDS          Target: ARM Cortex-A9\n"
        " RVDS_ARM_CM0                     - Compiller: RVDS          Target: ARM Cortex-M0\n"
        " RVDS_ARM_CM3                     - Compiller: RVDS          Target: ARM Cortex-M3\n"
        " RVDS_ARM_CM4_MPU                 - Compiller: RVDS          Target: ARM Cortex-M4 with MPU\n"
        " RVDS_ARM_CM4F                    - Compiller: RVDS          Target: ARM Cortex-M4 with FPU\n"
        " RVDS_ARM_CM7                     - Compiller: RVDS          Target: ARM Cortex-M7\n"
        " RVDS_ARM7_LPC21XX                - Compiller: RVDS          Target: ARM7 LPC21xx\n"
        " SDCC_CYGNAL                      - Compiller: SDCC          Target: Cygnal\n"
        " SOFTUNE_MB91460                  - Compiller: Softune       Target: MB91460\n"
        " SOFTUNE_MB96340                  - Compiller: Softune       Target: MB96340\n"
        " TASKING_ARM_CM4F                 - Compiller: Tasking       Target: ARM Cortex-M4 with FPU\n"
        " CDK_THEAD_CK802                  - Compiller: CDK           Target: T-head CK802\n"
        " XCC_XTENSA                       - Compiller: XCC           Target: Xtensa\n"
        " WIZC_PIC18                       - Compiller: WizC          Target: PIC18")
elseif((FREERTOS_PORT STREQUAL "A_CUSTOM_PORT") AND (NOT TARGET freertos_kernel_port) )
    message(FATAL_ERROR " FREERTOS_PORT is set to A_CUSTOM_PORT. Please specify the custom port target with all necessary files. For example:\n"
    " Assuming a directory of:\n"
    "  FreeRTOSCustomPort/\n"
    "    CMakeLists.txt\n"
    "    port.c\n"
    "    portmacro.h\n\n"
    " Where FreeRTOSCustomPort/CMakeLists.txt is a modified version of:\n"
    "   add_library(freertos_kernel_port STATIC)\n\n"
    "   target_sources(freertos_kernel_port\n"
    "     PRIVATE\n"
    "       portcomm.c\n"
    "       portmacro.h)\n\n"
    "   target_include_directories(freertos_kernel_port\n"
    "     PUBLIC\n"
    "      .)\n\n"
    "   taget_link_libraries(freertos_kernel_port\n"
    "     PRIVATE\n"
    "       freertos_kernel)")
endif()

add_subdirectory(portable)

add_library(freertos_kernel STATIC
    croutine.c
    event_groups.c
    list.c
    queue.c
    stream_buffer.c
    tasks.c
    timers.c

    # If FREERTOS_HEAP is digit between 1 .. 5 - it is heap number, otherwise - it is path to custom heap source file
    $<IF:$<BOOL:$<FILTER:${FREERTOS_HEAP},EXCLUDE,^[1-5]$>>,${FREERTOS_HEAP},portable/MemMang/heap_${FREERTOS_HEAP}.c>
)

target_include_directories(freertos_kernel
    PUBLIC
        include
)

target_link_libraries(freertos_kernel 
    PUBLIC 
        freertos_config
        freertos_kernel_port
)
