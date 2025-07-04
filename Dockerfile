FROM --platform=linux/amd64 python:3.9-slim

# Set working directory
WORKDIR /app

# Install uv
RUN pip install uv

# Copy only dependency definition first for better layer caching
COPY pyproject.toml .

# Install dependencies using uv without virtual environment
RUN uv pip install --system -e .

# Copy the rest of the application
COPY . .

# Run the application
CMD ["python", "src/main.py"]
