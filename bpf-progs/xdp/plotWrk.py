import subprocess
import re
import numpy as np

# Configure matplotlib to use Agg backend
import matplotlib
# Agg backend doesn't require GUI
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Function to run wrk command and parse the output
def run_wrk():
    command = "wrk -t6 -c200 -d30s http://10.0.2.15:80/index.html"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    output = result.stdout

    # Extracting latency and throughput from the output using regex
    latency_match = re.search(r'Latency\s+(\d+\.\d+)ms', output)
    requests_sec_match = re.search(r'Requests/sec:\s+(\d+\.\d+)', output)

    latency = float(latency_match.group(1)) if latency_match else None
    requests_sec = float(requests_sec_match.group(1)) if requests_sec_match else None

    return latency, requests_sec

# Lists to store latency and throughput values
latencies = []
throughputs = []

# Run the wrk command 20 times
for i in range(20):
    latency, throughput = run_wrk()
    if latency is not None and throughput is not None:
        latencies.append(latency)
        throughputs.append(throughput)
    print(f"Run {i+1}: Latency = {latency} ms, Throughput = {throughput} requests/sec")

# Convert lists to numpy arrays for easier calculation of mean and standard deviation
latencies = np.array(latencies)
throughputs = np.array(throughputs)

# Calculate mean and standard deviation
latency_mean = np.mean(latencies)
latency_std = np.std(latencies)
throughput_mean = np.mean(throughputs)
throughput_std = np.std(throughputs)

# Plotting the results
fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.errorbar(range(1, 21), latencies, yerr=latency_std, fmt='-o', label='Latency (ms)', color='b')
ax2.errorbar(range(1, 21), throughputs, yerr=throughput_std, fmt='-o', label='Throughput (requests/sec)', color='r')

ax1.set_xlabel('Run')
ax1.set_ylabel('Latency (ms)', color='b')
ax2.set_ylabel('Throughput (requests/sec)', color='r')

ax1.tick_params(axis='y', colors='b')
ax2.tick_params(axis='y', colors='r')

fig.tight_layout()
plt.title('Latency and Throughput Over 20 Runs')
plt.legend()

# Save the plot as a .png file
plt.savefig('benchmark_results.png')
