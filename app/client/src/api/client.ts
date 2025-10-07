// API client configuration

// Base URL configuration - works in both dev and production
const API_BASE_URL = import.meta.env.DEV 
  ? '/api'  // Proxy to backend in development
  : 'http://localhost:8000/api';  // Direct backend in production

// Generic API request function
async function apiRequest<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const url = `${API_BASE_URL}${endpoint}`;
  
  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('API request failed:', error);
    throw error;
  }
}

// API methods
export const api = {
  // Upload file
  async uploadFile(file: File): Promise<FileUploadResponse> {
    const formData = new FormData();
    formData.append('file', file);
    
    return apiRequest<FileUploadResponse>('/upload', {
      method: 'POST',
      body: formData
    });
  },
  
  // Process query
  async processQuery(request: QueryRequest): Promise<QueryResponse> {
    return apiRequest<QueryResponse>('/query', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(request)
    });
  },
  
  // Get database schema
  async getSchema(): Promise<DatabaseSchemaResponse> {
    return apiRequest<DatabaseSchemaResponse>('/schema');
  },
  
  // Generate insights
  async generateInsights(request: InsightsRequest): Promise<InsightsResponse> {
    return apiRequest<InsightsResponse>('/insights', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(request)
    });
  },
  
  // Health check
  async healthCheck(): Promise<HealthCheckResponse> {
    return apiRequest<HealthCheckResponse>('/health');
  },
  
  // Generate random query
  async generateRandomQuery(): Promise<RandomQueryResponse> {
    return apiRequest<RandomQueryResponse>('/generate-random-query');
  },

  // Export table as CSV
  async exportTable(tableName: string): Promise<void> {
    const url = `${API_BASE_URL}/export/table/${encodeURIComponent(tableName)}`;

    try {
      const response = await fetch(url);

      if (!response.ok) {
        throw new Error(`Export failed: ${response.status}`);
      }

      // Get the blob from response
      const blob = await response.blob();

      // Create a download link and trigger it
      const downloadUrl = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = downloadUrl;
      link.download = `${tableName}_export.csv`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      // Clean up the URL object
      window.URL.revokeObjectURL(downloadUrl);
    } catch (error) {
      console.error('Table export failed:', error);
      throw error;
    }
  },

  // Export query results as CSV
  async exportQueryResults(sql: string, columns: string[]): Promise<void> {
    const url = `${API_BASE_URL}/export/query`;

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ sql, columns })
      });

      if (!response.ok) {
        throw new Error(`Export failed: ${response.status}`);
      }

      // Get the blob from response
      const blob = await response.blob();

      // Create a download link and trigger it
      const downloadUrl = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = downloadUrl;
      link.download = `query_results_${new Date().toISOString().slice(0, 19).replace(/[:-]/g, '')}.csv`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      // Clean up the URL object
      window.URL.revokeObjectURL(downloadUrl);
    } catch (error) {
      console.error('Query export failed:', error);
      throw error;
    }
  }
};