# NuttX Workspace

This repository contains the NuttX RTOS workspace with separate submodules for the kernel and applications.

## Structure

- `apps/`: NuttX applications repository
- `nuttx/`: NuttX kernel repository

## Setup

After cloning this repository, initialize the submodules:

```bash
git submodule update --init --recursive
```

## Building

To build NuttX, go to the nuttx directory:

```bash
cd nuttx
./tools/configure.sh [configuration]
make
```


