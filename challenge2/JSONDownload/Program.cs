using Azure.Storage.Blobs;
using Microsoft.Azure;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;

namespace JSONDownload
{
    public class Program
    {
        public static void Main(string[] args)
        {
            string connectionString = CloudConfigurationManager.GetSetting("BlobConnectionString");
            BlobContainerClient container = new BlobContainerClient(connectionString, "challenge2blob");
            var blockBlob = container.GetBlobClient("download/EmployeeData.json");
            using (var fileStream = System.IO.File.OpenWrite(@"C:\Users\sagarwa5\Downloads\Output\result.json"))
            {
                blockBlob.DownloadTo(fileStream);
            }

            List<Employee> ro = new List<Employee>();
            using (StreamReader r = new StreamReader(@"C:\Users\sagarwa5\Downloads\Output\result.json"))
            {
                string json = r.ReadToEnd();
                Console.Write(json);
                Console.ReadLine();
                //ro = JsonConvert.DeserializeObject<List<Employee>>(json);
            }

        }
    }
}
