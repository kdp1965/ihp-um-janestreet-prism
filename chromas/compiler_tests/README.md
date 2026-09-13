# yosys-prism compiler regression

`chroma_split.v` exercises the state-encoding rules of `synth_prism` with
the dual-compare cfg (`../tinyqv32.cfg`):

- "if / else next-state" (any number of conditions that fit the trees)
  encodes the else with `Inc=1`, which in hardware starts or continues the
  automatic loop: the following states' no-match path returns to the first
  INC state, so conditions spread over consecutive states keep being
  evaluated;
- a 5-way state (4 conditions + stay) splits into a partial upper row with
  `Inc=1` and a lower row whose stay is the default output slot (the loop
  back returns to the upper row);
- "2 conditions + else -> some other state" splits, with the else as a tree
  jump in the lower row;
- a lone unconditional jump (no condition in front of it) is a tree jump,
  not INC;
- stay-only and "1 condition + stay" rows use the default path and leave the
  unused tree's LUT at 0;
- an undefined state row still jumps to state 0 through tree 0.

Build and compare against `chroma_split.expected.lst`:

    ../../../yosys-prism/yosys -q -p 'read_verilog chroma_split.v; synth; \
        synth_prism -cfg ../tinyqv32.cfg -top chroma_split -list /tmp/split.lst'
    diff /tmp/split.lst chroma_split.expected.lst
