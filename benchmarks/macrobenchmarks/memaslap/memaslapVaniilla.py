import re
import subprocess
import numpy as np
import matplotlib.pyplot as plt

def extract_statistics(output):
    get_pattern = re.compile(
        r'Get Statistics\s*Type\s+Time\(s\)\s+Ops\s+TPS\(ops/s\)\s+Net\(M/s\)\s+Get_miss\s+Min\(us\)\s+Max\(us\)\s+Avg\(us\)\s+Std_dev\s+Geo_dist\s*Period\s+(\d+)\s+(\d+)\s+(\d+)\s+([\d.]+)\s+([\d.]+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([\d.]+)\s+([\d.]+)'
    )
    set_pattern = re.compile(
        r'Set Statistics\s*Type\s+Time\(s\)\s+Ops\s+TPS\(ops/s\)\s+Net\(M/s\)\s+Get_miss\s+Min\(us\)\s+Max\(us\)\s+Avg\(us\)\s+Std_dev\s+Geo_dist\s*Period\s+(\d+)\s+(\d+)\s+(\d+)\s+([\d.]+)\s+([\d.]+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([\d.]+)\s+([\d.]+)'
    )

    get_matches = get_pattern.findall(output)
    set_matches = set_pattern.findall(output)

    # Data containers
    get_data = {
        'interval': [],
        'tps': [],
        'latency_avg': [],
        'latency_stddev': [],
        'geo_dist': []
    }

    set_data = {
        'interval': [],
        'tps': [],
        'latency_avg': [],
        'latency_stddev': [],
        'geo_dist': []
    }

    # Helper function to calculate cumulative intervals
    def get_cumulative_intervals(matches):
        cumulative_interval = 0
        interval_data = []
        for match in matches:
            period, ops, tps, net_m, get_miss, min_us, max_us, avg_us, std_dev, geo_dist = match
            period = int(period)
            cumulative_interval += period
            interval_data.append(cumulative_interval)
            interval_data.append(int(tps))
            interval_data.append(float(avg_us))
            interval_data.append(float(std_dev))
            interval_data.append(float(geo_dist))
        return interval_data

    # Extracting Get data
    get_matches_data = get_cumulative_intervals(get_matches)
    get_data['interval'] = get_matches_data[0::5]
    get_data['tps'] = get_matches_data[1::5]
    get_data['latency_avg'] = get_matches_data[2::5]
    get_data['latency_stddev'] = get_matches_data[3::5]
    get_data['geo_dist'] = get_matches_data[4::5]

    # Extracting Set data
    set_matches_data = get_cumulative_intervals(set_matches)
    set_data['interval'] = set_matches_data[0::5]
    set_data['tps'] = set_matches_data[1::5]
    set_data['latency_avg'] = set_matches_data[2::5]
    set_data['latency_stddev'] = set_matches_data[3::5]
    set_data['geo_dist'] = set_matches_data[4::5]

    return get_data, set_data

def plot_tps_with_error_bars(ax, intervals, tps, label):
    tps_std_dev = np.std(tps)
    ax.errorbar(intervals, tps, yerr=tps_std_dev, fmt='o-', capsize=5, label=label)

    for i in range(len(intervals)):
        x = intervals[i]
        y = tps[i]
        std_dev = tps_std_dev
        ax.annotate(f'{y:.2f}', (x, y), textcoords="offset points", xytext=(0,5), ha='center', fontsize=6)
        ax.annotate(f'{y + std_dev:.2f}', (x, y + std_dev), textcoords="offset points", xytext=(0,5), ha='center', fontsize=6)
        ax.annotate(f'{y - std_dev:.2f}', (x, y - std_dev), textcoords="offset points", xytext=(0,-15), ha='center', fontsize=6)

    ax.set_xlabel('Interval (s)')
    ax.set_ylabel('TPS (ops/s)')
    ax.set_title(f'{label} TPS')
    ax.set_xticks(intervals)
    ax.legend()
    ax.grid(True)

def plot_latency_with_error_bars(ax, intervals, latency_avg, latency_stddev, label):
    ax.errorbar(intervals, latency_avg, yerr=latency_stddev, fmt='o-', capsize=5, label=label)

    for i in range(len(intervals)):
        x = intervals[i]
        y = latency_avg[i]
        std_dev = latency_stddev[i]
        ax.annotate(f'{y:.2f}', (x, y), textcoords="offset points", xytext=(0,5), ha='center', fontsize=6)
        ax.annotate(f'{y + std_dev:.2f}', (x, y + std_dev), textcoords="offset points", xytext=(0,5), ha='center', fontsize=6)
        ax.annotate(f'{y - std_dev:.2f}', (x, y - std_dev), textcoords="offset points", xytext=(0,-15), ha='center', fontsize=6)

    ax.set_xlabel('Interval (s)')
    ax.set_ylabel('Latency (us)')
    ax.set_title(f'{label} Latency')
    ax.set_xticks(intervals)
    ax.legend()
    ax.grid(True)


def clean_output(output):
    # Regular expression to match ANSI escape codes
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')

    # Remove ANSI escape codes from output
    cleaned_output = ansi_escape.sub('', output)
    return cleaned_output

def run_memaslap_and_capture_output():
    # Define the memaslap command
    memaslap_cmd = [
        "memaslap",
        "-s", "192.168.100.2:11211",
        "-T", "2",
        "-c", "1024",
        "-n", "1",
        "-t", "240",
        "--stat_freq=20s"
    ]

    try:
        # Run the command and capture its output
        result = subprocess.run(memaslap_cmd, capture_output=True, text=True, check=True)
        output = result.stdout

        # Clean up output to remove ANSI escape codes
        cleaned_output = clean_output(output)

        return cleaned_output
    except subprocess.CalledProcessError as e:
        print(f"Error while running memaslap: {e}")
        return None


def aggregate_statistics(runs_data):
    # Initialize lists to accumulate values
    all_intervals = []
    all_tps = []
    all_latency_avg = []
    all_latency_stddev = []

    for run_data in runs_data:
        get_data, set_data = run_data

        # Append data for 'Get' and 'Set'
        all_intervals.extend(get_data['interval'])
        all_tps.extend(get_data['tps'])
        all_latency_avg.extend(get_data['latency_avg'])
        all_latency_stddev.extend(get_data['latency_stddev'])

    # Compute aggregated statistics
    intervals = sorted(set(all_intervals))
    mean_tps = [np.mean([tps for i, tps in zip(all_intervals, all_tps) if i == interval]) for interval in intervals]
    mean_latency_avg = [np.mean([latency for i, latency in zip(all_intervals, all_latency_avg) if i == interval]) for interval in intervals]
    mean_latency_stddev = [np.mean([stddev for i, stddev in zip(all_intervals, all_latency_stddev) if i == interval]) for interval in intervals]
    stddev_tps = [np.std([tps for i, tps in zip(all_intervals, all_tps) if i == interval]) for interval in intervals]

    aggregated_get_data = {
        'interval': intervals,
        'tps': mean_tps,
        'latency_avg': mean_latency_avg,
        'latency_stddev': mean_latency_stddev,
        'geo_dist': []  # Not aggregated in this example
    }

    aggregated_set_data = {
        'interval': intervals,
        'tps': mean_tps,
        'latency_avg': mean_latency_avg,
        'latency_stddev': mean_latency_stddev,
        'geo_dist': []  # Not aggregated in this example
    }

    return aggregated_get_data, aggregated_set_data


def main():
    runs = 10
    all_runs_data = []

    for _ in range(runs):
        output = run_memaslap_and_capture_output()
        if output:
            get_data, set_data = extract_statistics(output)
            all_runs_data.append((get_data, set_data))
        else:
            print("Failed to capture output from memaslap command.")
            return

    # Aggregate results
    aggregated_get_data, aggregated_set_data = aggregate_statistics(all_runs_data)

    # Plotting TPS and Latency
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(14, 10))

    # Plot Get TPS with error bars
    plot_tps_with_error_bars(ax1, aggregated_get_data['interval'], aggregated_get_data['tps'], label='Get')

    # Plot Set TPS with error bars
    plot_tps_with_error_bars(ax2, aggregated_set_data['interval'], aggregated_set_data['tps'], label='Set')

    # Plot Get Latency with error bars
    plot_latency_with_error_bars(ax3, aggregated_get_data['interval'], aggregated_get_data['latency_avg'], aggregated_get_data['latency_stddev'], label='Get')

    # Plot Set Latency with error bars
    plot_latency_with_error_bars(ax4, aggregated_set_data['interval'], aggregated_set_data['latency_avg'], aggregated_set_data['latency_stddev'], label='Set')

    # Save the figure as PNG
    plt.tight_layout()
    plt.savefig('statistics_plots_vanilla.png')
    plt.close()

    print("Plots saved successfully.")

if __name__ == '__main__':
    main()
