FROM --platform=linux/amd64 python:3.9-slim

WORKDIR /app

# Install uv
RUN pip install uv

# Copy the application files
COPY . .

# Install dependencies using uv
RUN uv pip install .

# Run the application
CMD ["python", "src/main.py"]
