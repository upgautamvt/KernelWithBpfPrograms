import re
import matplotlib.pyplot as plt

# Initialize lists to store extracted data
latency_avg = []
latency_stdev = []
iteration_numbers = []

# Read the output from file
with open('output.txt', 'r') as f:
    # Read entire content
    wrk_outputs = f.read()

# Regex patterns to extract relevant metrics
pattern_latency = r"Latency\s+([\d.]+)us\s+([\d.]+)us\s+([\d.]+)ms\s+([\d.]+)%"

# Extract data from each output using regex
outputs = wrk_outputs.strip().split("\n\n")
iteration_count = 1
for output in outputs:
    # Extract Latency
    match = re.search(pattern_latency, output)
    if match:
        # Extract values and convert to float
        avg = float(match.group(1))
        stdev = float(match.group(2))
        # Append to lists
        latency_avg.append(avg)
        latency_stdev.append(stdev)
        iteration_numbers.append(iteration_count)
        iteration_count += 1

# Plotting latency with error bars and connecting points with a line
plt.figure(figsize=(10, 6))
if latency_avg and latency_stdev:
    plt.errorbar(iteration_numbers, latency_avg, yerr=latency_stdev, fmt='o', capsize=5, label='Latency', linestyle='-', linewidth=1)
else:
    plt.plot(iteration_numbers, latency_avg, marker='o', linestyle='-', color='b', label='Latency')
plt.xticks(iteration_numbers)
plt.xlabel('Iteration')
plt.ylabel('Latency (µs)')
plt.title('Latency vs Iteration')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig('latency_with_error_bar.png')  # Save plot to PNG
plt.close()
