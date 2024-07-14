import re
import statistics
import matplotlib.pyplot as plt

# Initialize lists to store extracted data
latency_avg = []
latency_stdev = []
transfer_sec = []
iteration_numbers = []

# Read the output from file
with open('output.txt', 'r') as f:
    # Read entire content
    wrk_outputs = f.read()

# Regex patterns to extract relevant metrics
pattern_latency = r"Latency\s+([\d.]+)us\s+([\d.]+)us\s+([\d.]+)ms\s+([\d.]+)%"
pattern_transfer_sec = r"Transfer/sec:\s+([\d.]+[^\s]*)"

# Extract data from each output using regex
outputs = wrk_outputs.strip().split("\n\n")

# Extract Latency and Transfer/sec data
iteration_count = 1
for output in outputs:
    # Extract Latency
    match_latency = re.search(pattern_latency, output)
    if match_latency:
        avg = float(match_latency.group(1))
        stdev = float(match_latency.group(2))
        latency_avg.append(avg)
        latency_stdev.append(stdev)
    else:
        # Handle cases where regex doesn't match
        latency_avg.append(0)  # Placeholder value
        latency_stdev.append(0)  # Placeholder value

    # Extract Transfer/sec
    match_transfer_sec = re.search(pattern_transfer_sec, output)
    if match_transfer_sec:
        transfer_value = float(match_transfer_sec.group(1).replace('MB', ''))
        transfer_sec.append(transfer_value)
    else:
        # Handle cases where regex doesn't match
        transfer_sec.append(0)  # Placeholder value

    iteration_numbers.append(iteration_count)
    iteration_count += 1

# Calculate standard deviation of Transfer/sec
transfer_stdev = statistics.stdev(transfer_sec) if len(transfer_sec) > 1 else 0

# Debugging output to check lengths
print(f"Iterations: {len(iteration_numbers)}")
print(f"Latency Avg: {len(latency_avg)}")
print(f"Latency Stdev: {len(latency_stdev)}")
print(f"Transfer Sec: {len(transfer_sec)}")
print(f"Transfer Stdev: {transfer_stdev}")

# Plotting latency and throughput on a combined figure
plt.figure(figsize=(16, 6))

# Plot Latency on the left axis
plt.subplot(1, 2, 1)
if latency_avg and latency_stdev:
    plt.errorbar(iteration_numbers, latency_avg, yerr=latency_stdev, fmt='o', capsize=5, label='Latency')
else:
    plt.plot(iteration_numbers, latency_avg, marker='o', linestyle='-', label='Latency')
plt.xticks(iteration_numbers)
plt.xlabel('Iteration')
plt.ylabel('Latency (µs)')
plt.title('Latency vs Iteration')
plt.legend()
plt.grid(True)

# Connect Latency points
plt.plot(iteration_numbers, latency_avg, marker='o', linestyle='-')

# Plot Throughput on the right axis
plt.subplot(1, 2, 2)
if transfer_sec and transfer_stdev:
    plt.errorbar(iteration_numbers, transfer_sec, yerr=transfer_stdev, fmt='o', capsize=5, label='Transfer/sec')
else:
    plt.plot(iteration_numbers, transfer_sec, marker='o', linestyle='-', label='Transfer/sec')
plt.xticks(iteration_numbers)
plt.xlabel('Iteration')
plt.ylabel('Transfer/sec (MB)')
plt.title('Transfer/sec vs Iteration')
plt.legend()
plt.grid(True)

# Connect Transfer/sec points
plt.plot(iteration_numbers, transfer_sec, marker='o', linestyle='-')

plt.tight_layout()
plt.savefig('combined_latency_throughput.png')  # Save plot to PNG
plt.close()
