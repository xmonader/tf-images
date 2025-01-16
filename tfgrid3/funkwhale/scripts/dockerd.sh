#!/bin/bash
echo -500 > /proc/self/oom_score_adj
exec /usr/bin/dockerd -H unix:// --containerd=/run/containerd/containerd.sock
