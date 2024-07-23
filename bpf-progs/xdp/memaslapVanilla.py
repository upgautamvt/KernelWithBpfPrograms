import subprocess
import re
import numpy as np
import matplotlib.pyplot as plt

# Parameters
num_runs = 10
# now server is client
memaslap_cmd = "memaslap -s 192.168.100.2:11211 -T 2 -c 1024 -n 1 -t 10s"

# Arrays to store throughput and latency
throughputs = []
latencies = []

def run_memaslap():
    """Run the memaslap command and return throughput and latency values."""
    result = subprocess.run(memaslap_cmd, shell=True, capture_output=True, text=True)
    output = result.stdout

    # Extract throughput and latency values using regular expressions
    throughput_match = re.search(r'Run time:.*?Ops:\s*(\d+)', output)
    latency_match = re.search(r'Run time:.*?Net_rate:\s*([\d\.]+)M/s', output)

    if throughput_match and latency_match:
        throughput = int(throughput_match.group(1))
        latency = float(latency_match.group(1))
        return throughput, latency
    else:
        raise RuntimeError("Could not extract throughput or latency")

# Run memaslap tests
for i in range(num_runs):
    try:
        print(f"Running test {i + 1}/{num_runs}...")
        throughput, latency = run_memaslap()
        throughputs.append(throughput)
        latencies.append(latency)
    except RuntimeError as e:
        print(e)
        print(f"Skipping test {i + 1}/{num_runs} due to errors.")

# Convert lists to NumPy arrays for statistical calculations
throughputs = np.array(throughputs)
latencies = np.array(latencies)

# Compute averages and standard deviations
throughput_avg = np.mean(throughputs)
throughput_std = np.std(throughputs)
latency_avg = np.mean(latencies)
latency_std = np.std(latencies)

# Print out the results
print(f"Average Throughput: {throughput_avg:.2f} ops/sec ± {throughput_std:.2f}")
print(f"Average Latency: {latency_avg:.2f} M/s ± {latency_std:.2f}")

def plot_results():
    """Create a bar plot with error bars for throughput and latency."""
    fig, ax1 = plt.subplots()

    color = 'tab:blue'
    ax1.set_xlabel('Metric')
    ax1.set_ylabel('Throughput (ops/sec)', color=color)
    ax1.bar('Throughput', throughput_avg, yerr=throughput_std, color=color, alpha=0.6, capsize=5, label='Throughput')
    ax1.tick_params(axis='y', labelcolor=color)

    ax2 = ax1.twinx()
    color = 'tab:red'
    ax2.set_ylabel('Latency (M/s)', color=color)
    ax2.bar('Latency', latency_avg, yerr=latency_std, color=color, alpha=0.3, capsize=5, label='Latency')
    ax2.tick_params(axis='y', labelcolor=color)

    # Title and legend
    plt.title('Memaslap Vanilla Test Results')
    ax1.legend(loc='upper left')
    ax2.legend(loc='upper right')

    # Save plot to PNG file
    plt.savefig('memaslap_vanilla_results.png')

    print("Results saved to memaslap_vanilla_results.png")

# Call the function to plot the results
plot_results()
