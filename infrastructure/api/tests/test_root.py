from fastapi.testclient import TestClient
from examples.examples import app
import pytest
from unittest.mock import patch, MagicMock
import psycopg2
from azure.core.exceptions import HttpResponseError

client = TestClient(app)

# --- Mocks and Fixtures ---

# Set the environment variables for the tests
@pytest.fixture(autouse=True)
def set_env_vars(monkeypatch):
    monkeypatch.setenv("DATABASE_HOST", "localhost")
    monkeypatch.setenv("DATABASE_NAME", "testdb")
    monkeypatch.setenv("DATABASE_USER", "user")
    monkeypatch.setenv("DATABASE_PASSWORD", "password")
    monkeypatch.setenv("STORAGE_ACCOUNT_URL", "https://mockstorage.blob.core.windows.net/")

# Mock the psycopg2.connect function to simulate the PostgreSQL connection
@pytest.fixture
def mock_psycopg2_connect():
    with patch("examples.examples.psycopg2.connect") as mock_connect:
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [["example1"], ["example2"]]
        mock_conn.cursor.return_value = mock_cursor
        mock_connect.return_value = mock_conn
        yield mock_connect

# Mock the BlobServiceClient class to simulate the Azure Blob Storage client
@pytest.fixture
def mock_blob_service_client():
    with patch("examples.examples.BlobServiceClient") as mock_blob_service_client:
        mock_blob_service = MagicMock()
        mock_container_client = MagicMock()
        mock_blob_service.get_container_client.return_value = mock_container_client
        mock_container_client.download_blob.return_value.readall.return_value = b'["quote1", "quote2", "quote3"]'
        mock_blob_service_client.return_value = mock_blob_service
        yield mock_blob_service_client

# --- Successful Tests ---

# Test the / endpoint
def test_read_main():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"Hello": "World"}

# Test the /examples endpoint
def test_read_examples(mock_psycopg2_connect):
    response = client.get("/examples")
    assert response.status_code == 200
    assert response.json() == {"examples": [["example1"], ["example2"]]}

# Test the /quotes endpoint
def test_read_quotes(mock_blob_service_client):
    response = client.get("/quotes")
    assert response.status_code == 200
    assert response.json() == {"quotes": ["quote1", "quote2", "quote3"]}

# --- Generic Http Error Tests ---

# Test the unexpected error handling for the /examples endpoint
def test_read_examples_error():
    with patch("examples.examples.psycopg2.connect", side_effect=Exception("Database connection failed")):
        response = client.get("/examples")
        assert response.status_code == 500
        assert response.json() == {"detail": "Unexpected error: Database connection failed"}

# Test the unexpected error handling for the /quotes endpoint
def test_read_quotes_error():
    with patch("examples.examples.BlobServiceClient.get_container_client", side_effect=Exception("Container not found")):
        response = client.get("/quotes")
        assert response.status_code == 500
        assert response.json() == {"detail": "Unexpected error: Container not found"}

# --- Specific Http Error Tests ---

# Test the database error handling for the /examples endpoint
def test_read_examples_database_error():
    with patch("psycopg2.connect", side_effect=psycopg2.OperationalError("Database connection failed")):
        response = client.get("/examples")
        assert response.status_code == 500
        assert response.json() == {"detail": "Database error: Database connection failed"}

# Test the Blob error handling for the /quotes endpoint
def test_read_quotes_blob_error():
    with patch("examples.examples.BlobServiceClient") as mock_blob_service_client:
        mock_blob_service = MagicMock()
        mock_container_client = MagicMock()

        mock_container_client.download_blob.side_effect = HttpResponseError(
            "Blob not found",
            request=None,
            response=None
        )
        mock_blob_service.get_container_client.return_value = mock_container_client
        mock_blob_service_client.return_value = mock_blob_service

        response = client.get("/quotes")
        assert response.status_code == 500
        assert response.json() == {"detail": "Blob error: Blob not found"}
