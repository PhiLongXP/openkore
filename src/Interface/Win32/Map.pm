
#########################################################################
#	Win32::GUI Map Viewer for OpenKore
#	by: amacc_boy (koreadvance@yahoo.com)
#
#########################################################################
package Interface::Win32::Map;

use strict;
use Win32::GUI;
use Globals;
use Field;
use Misc;

my ($r_field,$W,$H,$DC,$bit,$DC2);
our $map_name;
our $mapOpened = 0;

our @input_que;

sub new {
	my $class = shift;
	my $self = {
		mw => undef,
	};
	bless $self, $class;

	return $self;
}

################################################################
# init
################################################################

sub initMapGUI {
	my $self = shift;
	
	$self->{mw} = new Win32::GUI::Window (
	    -left   => 0,
	    -top    => 0,
	    -width  => 300,
	    -height => 300,
	    -name   => "Window",
	    -text   => "Map Viewer: ",
	    -maximizebox => 0,
	    -minimizebox => 0,
	    -onTerminate => \&onexit, 
	    -resizable => 0,
	    -topmost => 1,
	);
	
	$mapOpened = 1;
	
	$self->{mw}->Show();
}
#Paint map in temporary dc before painting to window
sub paintMap {
	my $self = shift;
	
	$map_name = $field->baseName;
	$r_field = $field;
	
	$self->{mw}->Resize($field->width, $field->height +30);
    $W = $self->{mw}->ScaleWidth;
    $H = $self->{mw}->ScaleHeight;
    $DC = $self->{mw}->GetDC;
    $DC2 = $DC->CreateCompatibleDC();
    $bit = $DC->CreateCompatibleBitmap($W,$H); 
    $DC2->SelectObject($bit);
    
	my ($mvw_x,$mvw_y);
	$mvw_x = $field->width;
	$mvw_y = $field->height;
    
	for (my $j = 0; $j < $mvw_x; $j++) {
		for (my $k = 0; $k < $mvw_y; $k++) {
			my $block = $field->getBlock($j, $mvw_y-$k);
			if ($block == Field::WALKABLE) {
				$DC2->SetPixel($j, $k, [244,244,244],);
			} elsif ($block == Field::NON_WALKABLE) {
				$DC2->SetPixel($j, $k, [49,49,49],);
			} elsif ($block == Field::NON_WALKABLE_NON_SNIPABLE_WATER) {
				$DC2->SetPixel($j, $k, [0,100,210],);
			} elsif ($block == Field::WALKABLE_WATER) {
				$DC2->SetPixel($j, $k, [57,155,204],);
			} elsif ($block == Field::SNIPABLE_CLIFF) {
				$DC2->SetPixel($j, $k, [154,118,58],);
			}
		}
	}
	
	$DC->BitBlt(0, 0, $W,$H,$DC2, 0, 0);
    #We now delete the DC
    #$DC2->DeleteDC(); #Dont delete need for repainting
}

sub onexit {
	my $self = shift;
	
}

sub mapIsShown {
	return $mapOpened;
}

sub currentMap {
	return $map_name;
}

# Repaint Map by BitBlt from stored DC2 to DC
#
sub Repaint {
	return if (!$DC2);
	$DC->BitBlt(0, 0, $W,$H,$DC2, 0, 0);
}

# Paint own position
#
sub paintPos {
	my $self = shift;
	return unless defined($config{'char'}) && defined($chars[$config{'char'}]) && defined($char->{'pos_to'});
	my ($x,$y) = @{$char->{'pos_to'}}{'x', 'y'};
	
	my ($C,$left,$top,$right,$bottom);
	
	if ($self->mapIsShown()) {
		if ($map_name ne $r_field->name()) {
			$self->paintMap();
		}

		$self->{mw}->Caption("Map View: " . $field->baseName . " ($x,$y)");
		#$DC = $self->{mw}->GetDC;
		$C = new Win32::GUI::Pen(
            -color => [0,200,0], 
            -width => 5,
        );
        
        $DC->SelectObject($C);
        
        $left   = $x;
        $top    = $r_field->height()-$y;
        $right  = $left+3;
        $bottom = $top+3;
        $DC->Ellipse($left, $top, $right, $bottom);
	}
}

# Paint Position of monsters, players, npcs
#
sub paintMiscPos {
	my $self = shift;
	
	my ($C,$D,$E,$left,$top,$right,$bottom);
	
	if ($self->mapIsShown()) {
		#$DC = $self->{mw}->GetDC;
		$C = new Win32::GUI::Pen( #monster color
            -color => [214,40,58], 
            -width => 4,
        );

		$D = new Win32::GUI::Pen( #player color
            -color => [0,150,0], 
            -width => 4,
        );
        
		$E = new Win32::GUI::Pen( #npc color
            -color => [180,0,255], 
            -width => 4,
        );
                
        $DC->SelectObject($C);
		
		for (my $i = 0; $i < @monstersID; $i++) {
			next if ($monstersID[$i] eq "");
	        $left   = $monsters{$monstersID[$i]}{'pos'}{'x'};
	        $top    = $r_field->height()-$monsters{$monstersID[$i]}{'pos'}{'y'};
	        $right  = $left+3;
	        $bottom = $top+3;
	        $DC->Ellipse($left, $top, $right, $bottom);
		}

		$DC->SelectObject($D);

		for (my $i = 0; $i < @playersID; $i++) {
			next if ($playersID[$i] eq "");
	        $left   = $players{$playersID[$i]}{'pos'}{'x'};
	        $top    = $r_field->height()-$players{$playersID[$i]}{'pos'}{'y'};
	        $right  = $left+3;
	        $bottom = $top+3;
	        $DC->Ellipse($left, $top, $right, $bottom);
		}
				
		$DC->SelectObject($E);

		for (my $i = 0; $i < @npcsID; $i++) {
			next if ($npcsID[$i] eq "");
	        $left   = $npcs{$npcsID[$i]}{'pos'}{'x'};
	        $top    = $r_field->height()-$npcs{$npcsID[$i]}{'pos'}{'y'};
	        $right  = $left+3;
	        $bottom = $top+3;
	        $DC->Ellipse($left, $top, $right, $bottom);
		}
	}
}


1;
