
## Strange Issue 1:

### vdp_super code somehow corrupting non vdp_super mode screen output

In (src/vdp/vdp_super_res.sv)[src/vdp/vdp_super_res.sv] there is code to increment the vram address for rendering in `vdp_super` mode:

```
  if (active_line) begin
    super_res_vram_addr <= 17'(super_res_vram_addr + 4);
  end
```

The above code, increments 4 bytes for the `super_color` mode.  The plan is to change the incrementing value for `super_mid` and `super_res`.  (2 for `super_mid` and 1 for `super_color`)

So far so good.

There is related code in (src/vdp/address_bus.sv)[src/vdp/address_bus.sv]:

```
  if (vdp_super) begin
    IRAMADR <= super_vram_addr;
    PRAMDBO_8 <= 8'bZ;
    PRAMDBO_32 <= 32'bZ;
    PRAMWE_N <= 1'b1;
    PRAM_RD_SIZE <= `MEMORY_WIDTH_32;

  end else begin
```

The code above, is only activated when `vdp_super` is active, and will load the rendering vram byte address to the memory controller.

The `vdp_super` state does not activate until the register 31 is written to.  So in boot up, its initialised at 0.

This is proven, by adding a test point in the above code, to confirm the `vdp_super` block is never encountered until the register is explicitly updated by running a program to set the register.

Yet, if I change the vram address increment from 4 to 2, as below.  The screen image on boot up goes becomes a solid white colour.  That is, by changing the incrementing value, we somehow impacted normal screen modes (including the boot mode)

```
  if (active_line) begin
    super_res_vram_addr <= 17'(super_res_vram_addr + 2);
  end
```

If in (src/vdp/address_bus.sv)[src/vdp/address_bus.sv], I then comment out the address loading (which should not be happening since we are never in `vdp_super` mode), the normal screen modes work again.

```
  if (vdp_super) begin
    //IRAMADR <= super_vram_addr;
    PRAMDBO_8 <= 8'bZ;
    PRAMDBO_32 <= 32'bZ;
    PRAMWE_N <= 1'b1;
    PRAM_RD_SIZE <= `MEMORY_WIDTH_32;

  end else begin
```

#### Unknowns:

How can a state that is never encountered, somehow impact the operation?  Why does changing a vram address increment from 4 to 2 do this.

I have also confirmed, that the code to increment the address is also never encountered.  So its not even incrementing the address.

### Additional

There are 2 places where vram address is incremented.  Once at during the last line, and once at the end of each line.

As the vram address is set to 0 at the start of the last line.  Later on, during the last line, the first increment is applied.

## Observations

With the (src/vdp/vdp_super_res.sv)[src/vdp/vdp_super_res.sv]:
1. If the 2 vram increments are 4, then everything works as expected.
2. if the 2 vram increments are 2, then normal mode is corrupted.
3. if the first increment is 2 and the second increment is 4, then everything works as expected.
4. if the first increment is 4 and the second increment is 2, then everything works as expected.
5. if the first increment is changed to an explicit assignment (=2), then everything seems to work as expected.


Is there some optimisation issue with the synthesizer and layout?  Does it corrupt something, when I have 2 increments applied to vram at 2 distinct states?

## Worked Around

1. By having the first increment and absolute assignment, and not using trinary operator and instead explicit conditions - the underlying problem seems to have been resolved.  Except, when I removed the diagnostic LEDs from the circuit, the issue comes back.

2. Change place_option and route_option from 1 to 0 (0 being default) in tcl config:

```
set_option -place_option 0
set_option -route_option 0
```

  I do wonder if these settings had been the cause all along.