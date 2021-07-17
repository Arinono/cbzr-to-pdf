#!/usr/bin/env -S v run

import os
import core { check_args, process }

fn check_requirement() ? {
	println('Requirements check:')

	if os.execute('which convert').exit_code != 0 {
		eprintln("  Unable to use 'convert'. Please install 'ImageMagick'")
		$if macos {
			eprintln("  You can install it by running: 'brew install imagemagick'")
		}
		return error('Missing requirements')
	}
	if os.execute('which unrar').exit_code != 0 {
		eprintln("  Unable to use 'unrar'. Please install 'unrar'")
		$if macos {
			eprintln("  You can install it by running: 'brew install --cask unrar'")
		}
		return error('Missing requirements')
	}

	println('Requirements: OK\n')
	return
}

check_requirement() ?
files := check_args(os.args) ?
process(files)
