1. Introduction
===============

This folder contains various projects containing code pertaining to the Overboat.

2. Projects
===========

basic_model
-----------

Implements a crude inverse-bicycle model for the boat. Based mostly off of the wg1 code. Provides an estimate of energy usage and gain from solar panels. Includes autonomous waypoint controller from previous waypoint_control model.

GPS_node
--------

This is code for another microcontroller used to translate RS232 GPS data into CAN data. It has since been abandoned.

Paper_sim
---------

A simulation model built off of P�rez and Blanke 2002. Relient on many coefficients that need to be found experimentally, so it's not very accurate right now. Hopefully this will be the approach taken for the final boat model.