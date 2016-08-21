[![Build Status](https://travis-ci.org/Andrzej111/Linux-HeadphoneButton.svg?branch=master)](https://travis-ci.org/Andrzej111/Linux-HeadphoneButton)

NAME
====

Linux::HeadphoneButton - fires commands when headphone microphone button is pressed

SYNOPSIS
========

    #config.json
    { 
    "CLICK-INTERVAL" : "1",
    "ACTIONS" : {
        "S" : "command to run when short clicked", 
        "SS" : "double short click",
        "L" : "run when long click"
        "LSL" : "long-short-long sequence"
        //...
        }
    }
    # run with
    headphone_button

DESCRIPTION
===========

Linux::HeadphoneButton listens with `acpi_listen` for mic unplug - plug events Creates sequence and runs command defined in config.json file

AUTHOR
======

Paweł Szulc <pawel_szulc@onet.pl>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Paweł Szulc

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
