#!/bin/env perl

# Copyright 2015 Albert P. Tobey <tobert@gmail.com> @AlTobey
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use IPC::Open2;
use JSON;

while (1) {
    my $buf = "";
    my $size = read(STDIN, $buf, 4);
    if ($size == 4) {
        my $len = int($buf);
        $size = read(STDIN, $buf, $len);
        if ($size == $len) {
            my $data = decode_json($buf);

            # the react() function is defined in the actor definition
            react($data);
        } else {
            error_out("read $size bytes out of $len");
            next;
        }
    }
}

sub error_out {
    my $message = shift;
    print encode_json({ kind => "error", message => $message });
}
