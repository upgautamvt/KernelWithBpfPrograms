import re
import statistics
import matplotlib.pyplot as plt

# Initialize lists to store extracted data
transfer_sec = []
iteration_numbers = []

# Read the output from file
with open('output.txt', 'r') as f:
    # Read entire content
    wrk_outputs = f.read()

# Regex pattern to extract Transfer/sec
pattern_transfer_sec = r"Transfer/sec:\s+([\d.]+[^\s]*)"

# Extract data from each output using regex
outputs = wrk_outputs.strip().split("\n\n")
iteration_count = 1
for output in outputs:
    # Extract Transfer/sec
    match = re.search(pattern_transfer_sec, output)
    if match:
        # Extract value and convert to float
        transfer_value = float(match.group(1).replace('MB', ''))
        # Append to lists
        transfer_sec.append(transfer_value)
        iteration_numbers.append(iteration_count)
        iteration_count += 1

# Calculate standard deviation of Transfer/sec
transfer_stdev = statistics.stdev(transfer_sec)

# Plotting throughput (Transfer/sec) with error bars and connecting points with a line
plt.figure(figsize=(10, 6))
plt.errorbar(iteration_numbers, transfer_sec, yerr=transfer_stdev, fmt='o', capsize=5, label='Transfer/sec', linestyle='-', linewidth=1)
plt.plot(iteration_numbers, transfer_sec, marker='o', linestyle='-', color='b')  # Connect points with a line
plt.xticks(iteration_numbers)
plt.xlabel('Iteration')
plt.ylabel('Transfer/sec (MB)')
plt.title('Transfer/sec vs Iteration')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig('throughput_with_error_bar.png')  # Save plot to PNG
plt.close()
