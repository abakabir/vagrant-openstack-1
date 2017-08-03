#!/bin/bash

# vagrant-libvrt and/or landrush together have issues
# with starting multiple machines simultaneously. 
# This script just helps start them one-by-one.
vagrant up dir &&
vagrant up ctl1 &&
vagrant up ctl2 &&
vagrant up ctl3 &&
vagrant up cpt1 &&
vagrant up cpt2 
