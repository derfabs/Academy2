using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor;
using UnityEngine;

public class GUIControls : MonoBehaviour
{
    private float startW = 10;

    private float startH = 10;

    public float GUIRowIncrement = 50;

    public float GUIWidth = 340;

    public int GUIFontSize = 18;

    private int resolutionX = Screen.width;

    private int resolutionY = Screen.height;

    private GameObject m_CurrentElement;

    private Raycaster m_Raycaster;

    private StateManager m_StateManager;

    private float positionOffset = 2.0f;

    private float posX;

    private float posY;

    private float posZ;

    private float _posX;

    private float _posY;

    private float _posZ;

    public float minScale = 0.1f;

    public float maxScale = 3.0f;

    private float scaleX;

    private float scaleY;

    private float scaleZ;

    private float rotationX;

    private float rotationY;

    private float rotationZ;

    private bool load = false;

    private bool editPosition = false;

    private bool editRotation = false;

    private bool editScale = false;

    private bool mainMenu = true;

    private LogViewer m_Logs;

    void Start()
    {
        m_Raycaster = FindObjectOfType<Raycaster>();
        m_StateManager = FindObjectOfType<StateManager>();
        m_Logs = FindObjectOfType<LogViewer>();
    }

    void OnGUI()
    {
        GUI.skin.label.fontSize = GUIFontSize;
        GUI.skin.button.fontSize = GUIFontSize;
        int currentIdx = 0;
        int nextIdx = 0;

        nextIdx = enableElement(currentIdx);
    }

    int enableElement(int idx)
    {
        if (mainMenu)
        {
            if (
                GUI
                    .Button(new Rect(startW,
                        startH + GUIRowIncrement * idx,
                        GUIWidth,
                        GUIRowIncrement),
                    "Show/Hide Logs")
            )
            {
                m_Logs.Toggle();
            }
            idx++;

            if (
                GUI
                    .Button(new Rect(startW,
                        startH + GUIRowIncrement * idx,
                        GUIWidth,
                        GUIRowIncrement),
                    "Enable/Disable Raycaster")
            )
            {
                m_Raycaster.Toggle();
            }
            idx++;
            if (m_Raycaster.STATE)
            {
                idx++;
                if (
                    GUI
                        .Button(new Rect(startW,
                            startH + GUIRowIncrement * idx,
                            GUIWidth,
                            GUIRowIncrement),
                        "Show ALL")
                )
                {
                    m_StateManager.updateAll(State.VISIBLE, true);
                }
                idx++;
                if (
                    GUI
                        .Button(new Rect(startW,
                            startH + GUIRowIncrement * idx,
                            GUIWidth,
                            GUIRowIncrement),
                        "Hide ALL")
                )
                {
                    m_StateManager.updateAll(State.INVISIBLE, false);
                }
            }

            if (!m_Raycaster.STATE)
            {
                m_CurrentElement = m_Raycaster.hitGameObject;
                if (m_CurrentElement != null)
                {
                    show (m_CurrentElement);
                    load = true;
                }
            }

            if (load && !m_Raycaster.STATE)
            {
                GUI
                    .Label(new Rect(startW,
                        startH + GUIRowIncrement * idx,
                        GUIWidth,
                        90),
                    "Element Selected: " + m_CurrentElement.name);
                idx++;
                editPosition =
                    GUI
                        .Button(new Rect(startW,
                            startH + GUIRowIncrement * idx,
                            GUIWidth,
                            GUIRowIncrement),
                        "Edit Position");
                idx++;
                editRotation =
                    GUI
                        .Button(new Rect(startW,
                            startH + GUIRowIncrement * idx,
                            GUIWidth,
                            GUIRowIncrement),
                        "Edit Rotation");
                idx++;
                editScale =
                    GUI
                        .Button(new Rect(startW,
                            startH + GUIRowIncrement * idx,
                            GUIWidth,
                            GUIRowIncrement),
                        "Edit Scale");
                idx++;
                if (editPosition || editRotation || editScale)
                {
                    mainMenu = false;
                }
            }
        }

        if (editPosition && !mainMenu)
        {
            GUI
                .Label(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                "Edit Position: " + m_CurrentElement.name);
            idx++;
            idx = enablePositionUpdate(idx);
            if (
                GUI
                    .Button(new Rect(startW,
                        startH + GUIRowIncrement * idx,
                        GUIWidth,
                        GUIRowIncrement),
                    "set")
            )
            {
                mainMenu = true;
                editPosition = false;
                load = false;
            }
        }

        if (editRotation && !mainMenu)
        {
            GUI
                .Label(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                "Edit Rotation: " + m_CurrentElement.name);
            idx++;
            idx = enableRotationUpdate(idx);
            if (
                GUI
                    .Button(new Rect(startW,
                        startH + GUIRowIncrement * idx,
                        GUIWidth,
                        GUIRowIncrement),
                    "set")
            )
            {
                mainMenu = true;
                editRotation = false;
                load = false;
            }
        }

        if (editScale && !mainMenu)
        {
            GUI
                .Label(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                "Edit Scale" + m_CurrentElement.name);
            idx++;
            idx = enableScale(idx);
            if (
                GUI
                    .Button(new Rect(startW,
                        startH + GUIRowIncrement * idx,
                        GUIWidth,
                        GUIRowIncrement),
                    "set")
            )
            {
                mainMenu = true;
                editScale = false;
                load = false;
            }
        }
        return idx;
    }

    int enablePositionUpdate(int idx)
    {
        // -------------------------------------------
        //POSITION X
        float min = (_posX - positionOffset);
        float max = (_posX + positionOffset);
        GUI
            .Label(new Rect(startW,
                startH + GUIRowIncrement * idx,
                GUIWidth,
                90),
            $"PositionX: {posX}");
        idx++;

        posX =
            GUI
                .HorizontalSlider(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                posX,
                min,
                max);

        idx++;

        // -------------------------------------------
        //POSITION Y
        GUI
            .Label(new Rect(startW,
                startH + GUIRowIncrement * idx,
                GUIWidth,
                90),
            $"PositionY: {posY}");
        idx++;

        min = (_posY - positionOffset);
        max = (_posY + positionOffset);

        posY =
            GUI
                .HorizontalSlider(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                posY,
                min,
                max);

        idx++;

        // -------------------------------------------
        //POSITION Z
        GUI
            .Label(new Rect(startW,
                startH + GUIRowIncrement * idx,
                GUIWidth,
                90),
            $"PositionZ: {posZ}");
        idx++;

        min = (_posZ - positionOffset);
        max = (_posZ + positionOffset);

        posZ =
            GUI
                .HorizontalSlider(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                posZ,
                min,
                max);

        idx++;

        GUI
            .Label(new Rect(startW,
                startH + GUIRowIncrement * idx,
                GUIWidth,
                90),
            $"offset : {positionOffset}");
        idx++;

        positionOffset =
            GUI
                .HorizontalSlider(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                positionOffset,
                0,
                40);

        idx++;

        m_CurrentElement.transform.position = new Vector3(posX, posY, posZ);
        return idx;
    }

    int enableRotationUpdate(int idx)
    {
        // -------------------------------------------
        // X
        GUI
            .Label(new Rect(startW,
                startH + GUIRowIncrement * idx,
                GUIWidth,
                90),
            $"X: {rotationX}");
        idx++;

        rotationX =
            GUI
                .HorizontalSlider(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                rotationX,
                0.0f,
                360.0f);

        idx++;

        // -------------------------------------------
        // Y
        GUI
            .Label(new Rect(startW,
                startH + GUIRowIncrement * idx,
                GUIWidth,
                90),
            $"Y: {rotationY}");
        idx++;

        rotationY =
            GUI
                .HorizontalSlider(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                rotationY,
                0.0f,
                360.0f);

        idx++;

        // -------------------------------------------
        // Z
        GUI
            .Label(new Rect(startW,
                startH + GUIRowIncrement * idx,
                GUIWidth,
                90),
            $"Z: {rotationZ}");
        idx++;

        rotationZ =
            GUI
                .HorizontalSlider(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                rotationZ,
                0.0f,
                360.0f);

        idx++;

        m_CurrentElement.transform.eulerAngles =
            new Vector3(rotationX, rotationY, rotationZ);
        return idx;
    }

    int enableScale(int idx)
    {
        // -------------------------------------------
        // X
        GUI
            .Label(new Rect(startW,
                startH + GUIRowIncrement * idx,
                GUIWidth,
                90),
            $"Scale X: {scaleX}");
        idx++;

        scaleX =
            GUI
                .HorizontalSlider(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                scaleX,
                minScale,
                maxScale);

        idx++;

        // -------------------------------------------
        // Y
        GUI
            .Label(new Rect(startW,
                startH + GUIRowIncrement * idx,
                GUIWidth,
                90),
            $"Scale Y: {scaleY}");
        idx++;

        scaleY =
            GUI
                .HorizontalSlider(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                scaleY,
                minScale,
                maxScale);

        idx++;

        // -------------------------------------------
        // Z
        GUI
            .Label(new Rect(startW,
                startH + GUIRowIncrement * idx,
                GUIWidth,
                90),
            $"Scale Z : {scaleZ}");
        idx++;

        scaleZ =
            GUI
                .HorizontalSlider(new Rect(startW,
                    startH + GUIRowIncrement * idx,
                    GUIWidth,
                    GUIRowIncrement),
                scaleZ,
                minScale,
                maxScale);

        idx++;

        m_CurrentElement.transform.localScale =
            new Vector3(scaleX, scaleY, scaleZ);
        return idx;
    }

    void show(GameObject elem)
    {
        posX = elem.transform.position.x;
        posY = elem.transform.position.y;
        posZ = elem.transform.position.z;

        _posX = elem.transform.position.x;
        _posY = elem.transform.position.y;
        _posZ = elem.transform.position.z;

        rotationX = elem.transform.eulerAngles.x;
        rotationY = elem.transform.eulerAngles.y;
        rotationZ = elem.transform.eulerAngles.z;

        scaleX = elem.transform.localScale.x;
        scaleY = elem.transform.localScale.y;
        scaleZ = elem.transform.localScale.z;
    }
}

//restartButton.onClick.AddListener (restartState);
