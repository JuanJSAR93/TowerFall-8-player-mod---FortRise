#nullable enable
using System;
using System.IO;
using System.Reflection;

internal static class ValidateHarmony
{
    private const string GameDirectory = @"C:\Program Files (x86)\Steam\steamapps\common\TowerFall - FortRise2";
    private static readonly string ModuleDirectory =
        File.Exists(Path.Combine(AppContext.BaseDirectory, "..", "TF8PlayerFortRise.dll"))
            ? Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, ".."))
            : Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), @"Codex\2026-09-10\a\TF8PlayerFortRise");
    private const string PatchId = "TF8PlayerFortRise.validation";

    private static Assembly? ResolveAssembly(object? sender, ResolveEventArgs args)
    {
        string fileName = new AssemblyName(args.Name).Name + ".dll";
        foreach (string directory in new[] { GameDirectory, ModuleDirectory })
        {
            string candidate = Path.Combine(directory, fileName);
            if (File.Exists(candidate))
                return Assembly.LoadFrom(candidate);
        }

        return null;
    }

    public static int Main()
    {
        AppDomain.CurrentDomain.AssemblyResolve += ResolveAssembly;
        Environment.CurrentDirectory = GameDirectory;

        try
        {
            Assembly.LoadFrom(Path.Combine(GameDirectory, "TowerFall.Patch.dll"));
            Assembly module = Assembly.LoadFrom(Path.Combine(ModuleDirectory, "TF8PlayerFortRise.dll"));
            Assembly harmonyAssembly = Assembly.LoadFrom(Path.Combine(GameDirectory, "0Harmony.dll"));
            Type harmonyType = harmonyAssembly.GetType("HarmonyLib.Harmony", throwOnError: true)!;
            object harmony = Activator.CreateInstance(harmonyType, PatchId)!;
            harmonyType.GetMethod("PatchAll", new[] { typeof(Assembly) })!.Invoke(harmony, new object[] { module });
            // The validation process exits immediately, so its in-memory patches disappear with it.
            Console.WriteLine("Harmony validation passed: every declared TF8 patch was resolved and emitted in memory.");
            return 0;
        }
        catch (Exception exception)
        {
            Console.Error.WriteLine(exception);
            return 1;
        }
    }
}
