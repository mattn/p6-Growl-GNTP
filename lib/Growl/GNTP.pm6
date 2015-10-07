use v6;
unit class Growl::GNTP;

has Str $.Host = '127.0.0.1';
has Int $.Port = 23053;

method register(
    Str   :$AppName!,
    Array :$Notifications!,
) {
    my $sock = IO::Socket::INET.new(
        host => self.Host,
        port => self.Port,
    );
    my $count = @$Notifications.elems;
    my $form = qq:heredoc 'EOT';
GNTP/1.0 REGISTER NONE
EOT
    $sock.print($form.subst(/\n/, "\r\n", :g));
    $form = qq:heredoc 'EOT';
Application-Name: {{$AppName}}
Notifications-Count: {{$count.Str}}

EOT
    $sock.print($form.subst(/\n/, "\r\n", :g));

    for @$Notifications {
        $form = qq:heredoc 'EOT';
Notification-Name: {{.{'Name'}||'default'}}
Notification-Display-Name: {{.{'DisplayName'}||'default'}}
Notification-Enabled: {{.{'Enabled'}||'True'}}

EOT
        $sock.print($form.subst(/\n/, "\r\n", :g));
    }
    $sock.print("\r\n\r\n");
    my $line = $sock.get();
    if $line ~~ 'ERROR' {
        my $bt = '';
        while (my $line = $sock.get()) {
            last if $line.trim eq '';
            $bt ~= "{{$line.trim}}\n";
        }
        die $bt;
    }
    $sock.close;
}

method notify(
    Str  :$AppName!,
    Str  :$Name!,
    Str  :$Title!,
    Str  :$Text!,
    Str  :$ID? = '',
    Bool :$Sticky? = False,
    Int  :$Priority? = 1,
    Str  :$Icon? = '',
) {
    my $sock = IO::Socket::INET.new(
        host => self.Host,
        port => self.Port,
    );
    my $form = qq:heredoc 'EOT';
GNTP/1.0 NOTIFY NONE
EOT
    $sock.print($form.subst(/\n/, "\r\n", :g));
    $form = qq:heredoc 'EOT';
Application-Name: {{$AppName}}
Notification-Name: {{$Name}}
Notification-Title: {{$Title}}
Notification-ID: {{$ID}}
Notification-Priority: {{$Priority}}
Notification-Text: {{$Text}}
Notification-Sticky: {{$Sticky.Str}}
Notification-Icon: {{$Icon}}
Notification-Display-Name: {{"default"}}
EOT
    $sock.print($form.subst(/\n/, "\r\r\n", :g));
    $sock.print("\r\n");
    my $line = $sock.get();
    if $line ~~ 'ERROR' {
        my $bt = '';
        while (my $line = $sock.get()) {
            last if $line.trim eq '';
            $bt ~= "{{$line.trim}}\n";
        }
        die $bt;
    }
    $sock.close;
}

=begin pod

=head1 NAME

Growl::GNTP - blah blah blah

=head1 SYNOPSIS

  use Growl::GNTP;

=head1 DESCRIPTION

Growl::GNTP is ...

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Yasuhiro Matsumoto <mattn.jp@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
