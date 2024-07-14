import subprocess

# Define the command to run (wrk with parameters)
command = "wrk -t1 -c1 -d10s http://localhost:80"

# Static array to store outputs
output_array = []

# Run the command 20 times and append output to array
for i in range(20):
    print(f"Running iteration {i + 1}...")
    # Execute the command and capture output
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, text=True)
    # Append output to array
    output_array.append(result.stdout)
    print(f"Iteration {i + 1} complete.")

# Write all outputs from array to a file
with open('output.txt', 'w') as f:
    for output in output_array:
        f.write(output + '\n')

print("All iterations completed and results saved to 'output.txt'.")
