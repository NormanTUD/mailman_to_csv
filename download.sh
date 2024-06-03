function get_list_by_letter {
	curl=$1
	letter=$2
	$curl | tr '[:upper:]' '[:lower:]' | grep -vi "bgcolor" | grep -vi strong | grep -v "<td><center>$" | grep -v "center><center" 2>/dev/null
}

function parse_line_perl {
    perl -ne '
    use strict;
    use warnings;

    # Initialize a hash to store email data
    my %email_data;

    # Process each line
    while (my $line = <>) {
        # Check for lines with input checkboxes
        if ($line =~ /<input name="([^"]+)" type="checkbox" value="(on|off)"/i) {
            my ($name, $value) = ($1, $2);
            my ($email, $type) = split /_/, $name, 2;

            # Convert %40 to @ in email
            $email =~ s/%40/@/;

            # Initialize hash for new email
            $email_data{$email} = {mod => 0, hide => 0, nomail => 0, notmetoo => 0, nodupes => 0, digest => 0, plain => 0, language => "unknown"}
                unless exists $email_data{$email};

            # Set the value for the corresponding checkbox type
            $email_data{$email}{$type} = ($value eq "on") ? 1 : 0;
        }

        # Check for lines with selected language
        if ($line =~ /<select name="([^"]+)_language">/i) {
            my $email = $1;
            $email =~ s/%40/@/;

            # Read next line for the selected option
            my $option_line = <>;
            if ($option_line =~ /<option value="([^"]+)" selected>/i) {
                my $language = $1;

                # Initialize hash for new email if not already exists
                $email_data{$email} = {mod => 0, hide => 0, nomail => 0, notmetoo => 0, nodupes => 0, digest => 0, plain => 0, language => "unknown"}
                    unless exists $email_data{$email};

                # Set the selected language
                $email_data{$email}{language} = $language;
            }
        }
    }

    # Print the collected data
    foreach my $email (sort keys %email_data) {
        my $data = $email_data{$email};
        print join(",", $email, @$data{qw(mod hide nomail notmetoo nodupes digest plain language)}), "\n";

	warn "$email is wrong: $email" if $email !~ /@/;
    }
    '
}

#get_list_by_letter "j" | parse_line_perl

echo "email,mod,hide,nomail,notmetoo,nodupes,digest,plain,language"
for x in {a..z}; do
	get_list_by_letter $1 "$x" | parse_line_perl
done
