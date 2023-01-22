using System.Collections;
using UnityEngine;

public class LogViewer : MonoBehaviour
{
    public uint m_Queue = 15; // number of messages to keep

    Queue myLogQueue = new Queue();

    public int m_FontSize = 18;

    public int m_Width;

    private bool TOGGLE = true;

    void Start()
    {
        Debug.Log("Started up logging.");
        m_Width = Screen.width / 2;
    }

    public void Toggle()
    {
        TOGGLE = !TOGGLE;
    }

    void OnEnable()
    {
        Application.logMessageReceived += HandleLog;
    }

    void OnDisable()
    {
        Application.logMessageReceived -= HandleLog;
    }

    void HandleLog(string logString, string stackTrace, LogType type)
    {
        myLogQueue.Enqueue("[" + type + "] : " + logString);
        if (type == LogType.Exception) myLogQueue.Enqueue(stackTrace);
        while (myLogQueue.Count > m_Queue) myLogQueue.Dequeue();
    }

    void OnGUI()
    {
        if (TOGGLE)
        {
            GUI.skin.label.fontSize = m_FontSize;
            GUILayout
                .BeginArea(new Rect(Screen.width - m_Width,
                    0,
                    m_Width,
                    Screen.height));
            GUILayout.Label("\n" + string.Join("\n", myLogQueue.ToArray()));
            GUILayout.EndArea();
        }
    }
}
