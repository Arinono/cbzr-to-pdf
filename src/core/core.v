module core

import os
import io.util
import szip

pub fn check_args(av []string) ?[]string {
	paths := av[1..]
	if paths.len == 0 {
		return error('Usage: ./pdf-maker <file-path> [more-file-path]')
	}

	for f in paths {
		ext := os.file_ext(f)
		if ext != '.cbz' && ext != '.cbr' {
			return error('File must be a .cbz or .cbr')
		}
	}
	return paths
}

fn create_tmp_dir() ?string {
	dir := util.temp_dir(pattern: 'pdf-maker-') or {
		return error('Unable to create temporary directory to unpack file:$err.msg')
	}
	return dir
}

fn extract_tarball(dest string, file string) ? {
	ext := os.file_ext(file)
	match ext {
		'.cbz' {
			szip.extract_zip_to_dir(file, dest) or {
				return error('Unable to extract $file in $dest: $err.msg')
			}
		}
		'.cbr' {
			res := os.execute('unrar x ${escape(file)} $dest')
			if res.exit_code != 0 {
				return error('Unable to extract $file in $dest: $res.output')
			}
		}
		else {
			return error("Unsupported file extension: ${ext}. Please provide a '.cbz' or '.cbz'")
		}
	}
}

fn parse_int(s string) int {
	mut tmp_s := ''
	for c in s {
		if c <= 57 && c >= 48 {
			tmp_s += rune(c).str()
		}
	}
	return tmp_s.int()
}

fn escape(s string) string {
	return s.replace(' ', '\\ ').replace(')', '\\)').replace('(', '\\(').replace('[',
		'\\[').replace(']', '\\]')
}

fn get_files_paths(dir string, exts []string) []string {
	if !os.is_dir(dir) {
		return []
	}
	path_separator := os.path_separator
	mut files := os.ls(dir) or { return [] }
	mut res := []string{}
	separator := if dir.ends_with(path_separator) { '' } else { path_separator }
	files.sort_with_compare(fn (a &string, b &string) int {
		return if parse_int(a) < parse_int(b) { -1 } else { 1 }
	})
	for file in files {
		if file.starts_with('.') {
			continue
		}
		p := dir + separator + file
		if os.is_dir(p) && !os.is_link(p) {
			res << get_files_paths(p, exts)
		} else {
			for ext in exts {
				if file.ends_with(ext) {
					res << escape(p)
				}
			}
		}
	}
	return res
}

fn merge_paths(files []string) string {
	mut s := files.first()
	for f in files[1..] {
		s += ' $f'
	}
	return s
}

fn write_pdf(file string, imgs []string) ? {
	path := os.dir(file)
	name := os.base(file).split('.').first() + '.pdf'

	res := os.execute("convert ${merge_paths(imgs)} \"$path/$name\"")
	if res.exit_code != 0 {
		eprintln(res.output)
		return error('Unable to convert images to pdf for $file')
	}
	return
}

fn process_file(file string) ? {
	println('Proccessing file: $file')

	dir := create_tmp_dir() ?
	println('Extracting $file to $dir')
	extract_tarball(dir, file) ?
	println('Gathering the images for $file')
	imgs := get_files_paths(dir, ['.jpeg', '.jpg', '.png'])
	if imgs.len == 0 {
		return error('No images found in $dir for $file')
	}
	println('Converting $file')
	write_pdf(file, imgs) ?
	println('Cleaning temporary directory $dir for $file')
	os.rmdir_all(dir) or {
		return error("Unable to clean the temporary directory. Don't worry, it'll be done automatically by your computer later")
	}
	println('Successfully converted $file')
}

fn safe_process_file(f string) {
	process_file(f) or {
		eprintln(err)
	}
}

pub fn process(files []string) {
	for f in files {
		safe_process_file(f)
	}

	// I need to find a way to do this better.
	// The load is too big and it's too much. (11 files)
	// mut ths := []thread{}

	// for f in files {
	// 	ths << go safe_process_file(f)
	// }

	// ths.wait()
}
