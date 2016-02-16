#!/usr/bin/env bash
# prune incoming list of TV entries
egrep -v '(^		*"|^	.*\(TV\)|^	.*\(V\)|^	.*\(VG\))' 
