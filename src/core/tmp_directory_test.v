module core

import os

fn test_temporary_directory_creation() ? {
	// Arrange
	mut tmps := os.ls('/tmp') ?
	for p in tmps {
		tmp_path := '/tmp/$p'
		if p.starts_with('pdf-maker-') && os.is_dir(tmp_path) {
			os.rmdir_all(tmp_path) ?
		}
	}

	// Act
	path := create_tmp_dir() or {
		eprintln('Expected test to suceeded, but failed.')
		assert false
		return
	}

	// Assert
	assert path.contains('pdf-maker-')
	tmps = os.ls('/tmp') ?
	mut c := 0
	for p in tmps {
		tmp_path := '/tmp/$p'
		if p.starts_with('pdf-maker-') && os.is_dir(tmp_path) {
			c++
		}
	}
	assert c == 1

	// Cleanup
	os.rmdir_all(path) ?
}
