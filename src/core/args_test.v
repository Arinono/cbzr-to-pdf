module core

fn test_args_checking_no_files_provided() {
	// Arrange
	no_files := []string{len: 1, init: './bin'}

	// Act
	check_args(no_files) or {
		// Assert
		assert err.msg == 'Usage: ./pdf-maker <file-path> [more-file-path]'
		return
	}

	eprintln('Expected check to fail, but succeeded')
	assert false
}

fn test_args_checking_invalid_extension() {
	// Arrange
	mut no_files := []string{len: 1, init: './bin'}
	no_files << 'wrong-file.txt'

	// Act
	check_args(no_files) or {
		// Assert
		assert err.msg == 'File must be a .cbz or .cbr'
		return
	}

	eprintln('Expected check to fail, but succeeded')
	assert false
}

fn test_args_checking_valid_single_file() {
	// Arrange
	mut no_files := []string{len: 1, init: './bin'}
	no_files << 'valid-file.cbz'

	// Act
	files := check_args(no_files) or {
		// Assert
		eprintln('Expected check to succeed, but failed because: $err.msg')
		assert false
		return
	}

	assert files.len == 1
	assert files.first() == 'valid-file.cbz'
}

fn test_args_checking_valid_multi_file() {
	// Arrange
	mut no_files := []string{len: 1, init: './bin'}
	no_files << 'valid-file.cbz'
	no_files << 'valid-file.cbr'

	// Act
	files := check_args(no_files) or {
		// Assert
		eprintln('Expected check to succeed, but failed because: $err.msg')
		assert false
		return
	}

	assert files.len == 2
	assert files.first() == 'valid-file.cbz'
	assert files.last() == 'valid-file.cbr'
}
