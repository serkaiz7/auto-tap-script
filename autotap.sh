#!/data/data/com.termux/files/usr/bin/bash

# Function to show ASCII art
show_hamster() {
    cat << "EOF"
      ( )   
     (o o)  
    (  V  ) 
    --m-m--
EOF
}

# Check if required packages are installed
if ! command -v bc &> /dev/null; then
    echo "bc not found. Installing..."
    pkg install -y bc
fi

# Get user inputs
echo "Enter the duration of tapping in hours, minutes, or seconds (e.g., 1h, 30m, 45s): "
read duration

echo "Enter the delay before starting (in seconds): "
read delay

echo "Choose the position for tapping:
1. Center
2. Top
3. Bottom
4. Left
5. Right
6. Between Top and Center
7. Between Bottom and Center"
read position

echo "Enter the number of taps per second: "
read taps_per_second

echo "Enter the interval between taps in seconds: "
read interval_between_taps

# Get screen dimensions using dumpsys
screen_info=$(dumpsys display | grep -oP 'deviceWidth=\d+.*?deviceHeight=\d+')
screen_width=$(echo $screen_info | grep -oP 'deviceWidth=\d+' | grep -oP '\d+')
screen_height=$(echo $screen_info | grep -oP 'deviceHeight=\d+' | grep -oP '\d+')

# Define tap positions
center_x=$((screen_width / 2))
center_y=$((screen_height / 2))
top_y=100
bottom_y=$((screen_height - 100))
left_x=100
right_x=$((screen_width - 100))
btwn_top_center_y=$((center_y / 2))
btwn_bottom_center_y=$((center_y + (center_y / 2)))

# Determine tap coordinates based on user input
case $position in
    1) x=$center_x; y=$center_y ;;
    2) x=$center_x; y=$top_y ;;
    3) x=$center_x; y=$bottom_y ;;
    4) x=$left_x; y=$center_y ;;
    5) x=$right_x; y=$center_y ;;
    6) x=$center_x; y=$btwn_top_center_y ;;
    7) x=$center_x; y=$btwn_bottom_center_y ;;
    *) echo "Invalid option"; exit 1 ;;
esac

# Convert duration to seconds
duration_in_seconds=$(echo $duration | sed 's/h/*3600/; s/m/*60/; s/s/*1/' | bc)

# Show hamster ASCII art
show_hamster

# Wait for the specified delay
sleep $delay

# Calculate the interval between taps
interval=$(echo "scale=2; 1 / $taps_per_second" | bc)

# Execute the tap for the specified duration
end_time=$((SECONDS + duration_in_seconds))
while [ $SECONDS -lt $end_time ]; do
    for (( i=0; i<$taps_per_second; i++ )); do
        input tap $x $y
        sleep $interval_between_taps
    done
    sleep $interval_between_taps # Interval between tap sets
done

echo "Tapping completed."
