using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace challenge3
{
    public class Program
    {
        public static void Main(string[] args)
        {
            //pass nested dictionary and key to a method and get output
            var inputdict = new Dictionary<string, Dictionary<string, Dictionary<string, string>>>()
            {
                {
                    "Shr",
                        new Dictionary<string, Dictionary<string, string>>
                        {
                            {
                                "Professionalname",
                                    new Dictionary<string, string>
                                    {
                                        {"Firstname", "Shruti"}
                                    }
                            }
                        }
                },
                {
                    "Shashank",
                        new Dictionary<string, Dictionary<string, string>>
                        {
                            {
                                "Professionalname",
                                    new Dictionary<string, string>
                                    {
                                        {"Firstname", "Shashank"}
                                    }
                            }                            
                        }
                }
            };

            var result = GetValueFromKey(inputdict,"Shashank");
            foreach (var pair in result)
            {
                foreach (var innerPair in pair.Value)
                {
                    Console.WriteLine("{0} : {1} : {2}", pair.Key, innerPair.Key, innerPair.Value);
                    Console.ReadLine();
                }
            }

        }

        public static Dictionary<string, Dictionary<string, string>> GetValueFromKey(Dictionary<string, Dictionary<string, Dictionary<string, string>>> dict, string inputkey)
        {
            Dictionary<string, Dictionary<string, string>> outputVal = new Dictionary<string, Dictionary<string, string>>();
            if (dict.ContainsKey(inputkey))
            {
                outputVal = dict[inputkey];
            }

            return outputVal;
        }
    }
}
