# 5-Stage Pipelined MIPS Processor

A fully functional 5-stage MIPS pipeline processor implemented in Verilog.

## Pipeline Stages
IF → ID → EX → MEM → WB

## Features
- **Data Forwarding** — resolves RAW hazards without stalling
- **2-bit Saturating Branch Predictor** — reduces branch penalty
- **Hazard Detection Unit** — handles load-use hazards and flushes on misprediction

## Tools
- Quartus II (synthesis)
- ModelSim Altera (simulation)

## Simulation Results
![Waveform](waveform.png)

Registers $t0–$t3 correctly computed with forwarding active:
- $t0 = 5
- $t1 = 3  
- $t2 = 8 (forwarded from EX/MEM)
- $t3 = -5 (forwarded from MEM/WB)

## File Structure
| File | Description |
|------|-------------|
| `mips_pipeline.v` | Top-level module |
| `if_id_reg.v` | IF/ID pipeline register |
| `id_ex_reg.v` | ID/EX pipeline register |
| `ex_mem_reg.v` | EX/MEM pipeline register |
| `mem_wb_reg.v` | MEM/WB pipeline register |
| `forwarding_unit.v` | Data forwarding logic |
| `hazard_detection.v` | Stall and flush control |
| `branch_predictor.v` | 2-bit saturating counter BHT |
| `alu.v` | Arithmetic Logic Unit |
| `control_unit.v` | Main control decoder |
| `tb_mips_pipeline.v` | Testbench |
