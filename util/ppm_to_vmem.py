import sys

if len(sys.argv) != 3:
    print("Usage: python ppm_to_vmem.py [ppm_image_path] [vmem_file_path]")
    sys.exit(1)

assert(sys.argv[1].endswith(".ppm"))

# Read source PPM image
with open(sys.argv[1], "r") as f:
    ppm_text = f.read().replace("\n", " ")

# Check PPM format
ppm_parts = [i for i in ppm_text.split(" ") if i]
print(f"ppm parts: {len(ppm_parts)}")

assert(ppm_parts[0] == "P3")
assert(ppm_parts[3] == "255")

img_width = int(ppm_parts[1])
img_height = int(ppm_parts[2])

assert(img_width > 0)
assert((img_width & (img_width - 1)) == 0)
assert(img_height > 0)
assert(((img_width * img_height) % 4) == 0)

print(f"img size: {img_width}W x {img_height}H")

assert((img_width * img_height * 3 + 4) == len(ppm_parts))

# Check and consolidate major colors
color_map = {}

for i in range(img_width * img_height):
    r = int(ppm_parts[4 + i * 3])
    g = int(ppm_parts[4 + i * 3 + 1])
    b = int(ppm_parts[4 + i * 3 + 2])

    if (r, g, b) in color_map:
        color_map[(r, g, b)] += 1
    else:
        color_map[(r, g, b)] = 1

print(f"total colors: {len(color_map)}")

major_colors = []

for i in color_map:
    if color_map[i] >= ((img_width * img_height) / 10):
        major_colors.append(i)

print(f"major colors: {major_colors}")

assert(len(major_colors) <= 4)
assert(len(major_colors) > 0)

# Create major color to 2-bit mapping
major_color_map = {}
for i in range(len(major_colors)):
    major_color_map[major_colors[i]] = i+1

print(f"color mapping: {major_color_map}")

# Determine processed color and write output files
with open(sys.argv[2], "w") as vmem_out_f:
    vmem_out_f.write("@00000000\n")

    px_buffer = []

    for i in range(img_width * img_height):
        r = int(ppm_parts[4 + i * 3])
        g = int(ppm_parts[4 + i * 3 + 1])
        b = int(ppm_parts[4 + i * 3 + 2])

        major_color_distance = []
        for k in major_colors:
            distance = (k[0] - r)**2 + (k[1] - g)**2 + (k[2] - b)**2
            major_color_distance.append([k, distance])

        major_color_distance.sort(key=lambda x: x[1])

        px_buffer.append(major_color_map[major_color_distance[0][0]])

        if len(px_buffer) == 4:
            # Write byte containing 4 pixels
            data_byte = px_buffer[0] | (px_buffer[1] << 2) | (px_buffer[2] << 4) | (px_buffer[3] << 6)
            data_byte_str = hex(data_byte).replace("0x", "").zfill(2).upper()
            vmem_out_f.write(f"{data_byte_str}\n")

            # clear pixel buffer
            px_buffer = []
