# s6-node-alpine

A node alpine image that uses the [`s6-overlay`][s6] system to enable
a lightweight process runner that takes care of the PID 1 problem.


Uses `base-alpine` as the underpinning which includes the `s6-overlay`
