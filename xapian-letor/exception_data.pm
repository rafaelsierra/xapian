# exception_data.pm: details of the exception hierarchy used by Xapian.
package exception_data;
$copyright = <<'EOF';
/* Copyright (C) 2003,2004,2006,2007,2008,2009,2011,2015 Olly Betts
 * Copyright (C) 2007 Richard Boulton
 * Copyright (C) 2016 Ayush Tomar
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
 */
EOF

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
    $copyright $generated_warning @baseclasses @classes %subclasses %classcode
);

$generated_warning =
"/* Warning: This file is generated by $0 - do not modify directly! */\n";

@baseclasses = ();
@classes = ();
%subclasses = ();
%classcode = ();

sub errorbaseclass {
    push @baseclasses, \@_;
    push @{$subclasses{$_[1]}}, $_[0];
}

sub errorclass {
    my $typecode = shift;
    my ($class, $parent) = @_;
    push @classes, \@_;
    push @{$subclasses{$parent}}, $class;
    $classcode{$class} = $typecode;
}

errorbaseclass('LogicError', 'Error',
	       'The base class for exceptions indicating errors in the program logic.',
	       <<'DOC');
A subclass of LogicError will be thrown if Xapian detects a violation
of a class invariant or a logical precondition or postcondition, etc.
DOC

# RuntimeError and subclasses:

errorbaseclass('RuntimeError', 'Error',
	       'The base class for exceptions indicating errors only detectable at runtime.',
	       <<'DOC');
A subclass of RuntimeError will be thrown if Xapian detects an error
which is exception derived from RuntimeError is thrown when an
error is caused by problems with the data or environment rather
than a programming mistake.
DOC

errorclass(0, 'FileNotFoundError', 'RuntimeError',
	   'FileNotFoundError indicates that the file was not found at the path supplied.',
	   '');

errorclass(1, 'LetorParseError', 'RuntimeError',
	   'LetorParseError indicates file parsing error.',
	   <<'DOC');
You should check that the file being parsed follows the standard set by
xapian-letor.
DOC

errorclass(2, 'LetorInternalError', 'RuntimeError',
	   'LetorInternalError indicates a runtime problem of some sort.',
	   '');

sub for_each_nothrow {
    my $func = shift @_;
    my $class = '';
    foreach my $header ('include/xapian-letor.h', <include/xapian-letor/*.h>) {
	local $/ = undef;
	open H, '<', $header or die $!;
	my $header_text = <H>;
	# Strip comments, which might contain text describing XAPIAN_NOTHROW().
	$header_text =~ s!/(?:/[^\n]*|\*.*?\*/)! !gs;
	for (split /\n/, $header_text) {
	    if (/^\s*class\s+XAPIAN_VISIBILITY_DEFAULT\s+(\w+)/) {
		$class = "$1::";
		next;
	    }
	    if (/^[^#]*\bXAPIAN_NOTHROW\((.*)\)/) {
		&$func("Xapian::$class$1");
	    }
	}
	close H;
    }
}

1;
