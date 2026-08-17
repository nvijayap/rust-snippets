#!/usr/bin/env bash

# os.sh

trap "rm -f os.rs os" EXIT SIGINT SIGTERM

cat > os.rs <<!
fn main() {
  println!("Current OS: {}", std::env::consts::OS);
}
!

rustc os.rs && ./os
