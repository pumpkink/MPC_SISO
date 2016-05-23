// Copyright 2014 The MathWorks, Inc.

(function() {

    // Private object for storing a ref and its tooltip
    var href2Span = {};

    // Private function for extracting the recognized ref
    // (only href like #funX, #nodeX and #covX are supported)
    function getCandidateRef(href) {
        var res = undefined;
        try {
            if (typeof(href)==="string" && href.length > 4) {
                var ref = href.substring(1,4);
                if (ref=="fun" || ref=="cov" || ref=="nod") {
                    res = href.substring(1);
                }
            }
        } catch (err) {
        }
        return res;
    }
    
    // Initialize the candidates in the current document
    // (only register listener for element of class "lnk"
    // with a supported href)
    function register() {
        try {
            var lnks = document.getElementsByClassName("lnk");
            if (lnks) {
                for (var i = 0; i < lnks.length; i++) {
                    var lnk = lnks[i];
                    var ref = getCandidateRef(lnk.getAttribute("href"));
                    if (ref) {
                        addListener(lnk, "mouseover", openTooltip);
                    }
                }
            }
        } catch (err) {
        }
    }
    
    // Close/delete the current opened tooltip
    function closeTooltip(event) {
        // Close the tooltip if opened
        var sElem = href2Span["current"];
        if (sElem && sElem[1]) {
            // Close the tooltip
            sElem[1].removeChild(sElem[0]);
            href2Span["current"] = undefined;
            return;
        }
    }
    
    // Create/show a tooltip
    function openTooltip(event) {
        try {
            // Early return if not a supported candidate
            var ref = getCandidateRef(event.target.getAttribute("href"));
            if (!ref) {
                return;
            }
            
            // Close the current tooltip
            var sElem = href2Span["current"];
            if (sElem && sElem[1]) {
                sElem[1].removeChild(sElem[0]);
                href2Span["current"] = undefined;
            }
            
            // Create a new entry
            var obj = document.getElementsByName(ref);
            if (obj && obj[0].nextElementSibling) {
                var firstTable = obj[0].nextElementSibling.nextElementSibling;
                if (firstTable) {
                    var spanElem = document.createElement("span");
                    spanElem.className = "tooltip";
                    var newObj = undefined;
                    var subTables = firstTable.getElementsByTagName("table");
                    if (subTables.length > 1) {
                        if (ref.substring(0, 3)=="fun") {
                            // Skip the file/function info
                            newObj = subTables[1].cloneNode(true);
                        } else if (subTables.length > 2 && (ref.substring(0, 3)=="cov" || ref.substring(0, 4)=="node")) {
                            newObj = firstTable.cloneNode(true);
                            var trNodes = newObj.getElementsByTagName("tr");
                            if (trNodes) {
                                var tdNodes = trNodes[0].getElementsByTagName("td");
                                if (tdNodes) {
                                    tdNodes[0].setAttribute("width", "1");
                                }
                            }
                            
                            var newSubTables = newObj.getElementsByTagName("table");
                            var parentNode = newSubTables[0].parentNode;
                            parentNode.removeChild(newSubTables[0]);
                            var childNodes = parentNode.childNodes;
                            
                            for(var i = childNodes.length-1; i >= 0; i--){
                                var childNode = childNodes[i];
                                if(childNode.nodeName=="#text" || childNode.nodeName=="BR"){
                                    parentNode.removeChild(childNode);
                                } else if (childNode.nodeName=="B") {
                                    var newNode = document.createElement("br");
                                    parentNode.insertBefore(newNode, childNode);
                                }
                            }
                        }
                    }
                    
                    if (newObj) {
                        var aList = newObj.getElementsByTagName("a");
                        for(var i = 0; i < aList.length; i++) {
                            aList[i].removeAttribute("href");
                        }
                        spanElem.appendChild(newObj);
                        event.target.parentNode.appendChild(spanElem);
                        href2Span["current"] = [spanElem, event.target.parentNode];
                        addListener(spanElem, "click", closeTooltip);
                    }
                }
            }
        } catch (err) {
        }
    }

    // Helper for registering a listener
    function addListener(obj, type, fn) {
        if (obj.addEventListener) {
            obj.addEventListener(type, fn, false);
        } else if (obj.attachEvent) {
            obj.attachEvent("on" + type, fn);
        }
    }

    // Register the listener
    addListener(window, "load", register);

})();

