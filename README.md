# SPI MITM
(c) 2022 - MikeM64

This repository contains the design to intercept and dynamically switch the SPI controller attached to a given peripheral.

```
+------------+          +------+         +--------------+
|            |<---------+      |<--------+              |
| Peripheral |          | FPGA |         | Controller 0 |
|            +--------->|      +-------->|              |
+------------+          +-+----+         +--------------+
                          |   ^
                          |   |          +--------------+
                          |   +----------+              |
                          |              | Controller 1 |
                          +------------->|              |
                                         +--------------+
```

# Features
- Dynamically controlled switching between controller 0/1
- Two controlled interrupt pins, switchable between controller 0/1
- Monitoring of Controller 0 to Peripheral transfers (COPI) by controller 1 when controller 0 is active

# Requirements
- The repository as-is works on an Arty S7-50 board and would probably be easy to port to another Arty A-series or S-Series board
- Vivado 2020.2

# Usage
- controller1_spi_en_i:
    0: Controller 0 talks to the peripheral
    1: Controller 1 talks to the peripheral
- controller1_int_en_i:
    0: Controller 0 sees interrupt requests
    1: Controller 1 sees interrupt requests
