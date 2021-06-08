﻿<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeBehind="InfoCenter.aspx.cs" Inherits="FYP.InfoCenter" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link href="CSS/InfoCenter.css" rel="stylesheet" type="text/css" />
</asp:Content>



<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <h2>Google Map</h2><br />
    <!--  <p id="demo"></p>  -->
    <table class="topTable">
        <tr>
            <td><input id="input" type="text" style="height:75px;width:99%;float:left"/></td>
            <td>
                <div class="main">
                    <input id="slider" type="range" min="0" max="10000" value="5000" onclick ="suggestedResult()"/>
                        <div id="selector">
                            <div id="selectBtn"></div>
                            <div id="selectValue"></div>
                        </div>
                    <div id="progressBar"></div>
                </div>
                
            </td>
        </tr>
    </table>
    
   
    <table class="table">
        <tr>
            <td><div id="googleMap" class="googleMapCss"></div> </td>
            <td>
                <!-- Radio button -->
                
                <div class="searchedResults">

                    <input type="radio" id="recommended" name="option" value="recommended" checked="checked" onclick ="suggestedResult()">
                    <label for="recommended">Recommended</label>

                    <input type="radio" id="nearest" name="option" value="male" onclick ="suggestedResult()">
                    <label for="nearest">Nearest</label>

                    <input type="radio" id="mostRated" name="option" value="mostRated" onclick ="suggestedResult()">
                    <label for="mostRated">Most Rated</label>

                    <input type="radio" id="highestRating" name="option" value="highestRating"  onclick ="suggestedResult()">
                    <label for="highestRating">Highest Rating</label>

                    <input type="radio" id="showAll" name="option" value="showAll" onclick ="suggestedResult()">
                    <label for="showAll">Show All</label>
                    
                    <h2>Suggested location</h2>

                    <p id="demo"></p>
                    
                </div>

                <div class="autoCompleteResult">
                    <h2>Searched location</h2>
                    <p id="autoComplete"></p>
                </div>

                
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
    </table>
        
 
<!--<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCOs73MjrEETY_b9lbU9QCco5DoMll2UOY&sensor=false">  
</script>   -->

 
<script async
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCOs73MjrEETY_b9lbU9QCco5DoMll2UOY&libraries=places">
</script>

  
    <script type="text/javascript">  
        
        var slider = document.getElementById('slider');
        var radius = slider.value;
        var selector = document.getElementById('selector');
        var selectValue = document.getElementById('selectValue');
        var progressBar = document.getElementById('progressBar');

        selectValue.innerHTML = slider.value + "m";

        slider.oninput = function () {
            radius = this.value;
            selectValue.innerHTML = this.value + "m";
            selector.style.left = this.value/100 + "%";
            progressBar.style.width = this.value/100 + "%";
            
        }

        //document.getElementById("demo").innerHTML = 5 + 6;
        $(document).ready(function () {
            // Add your function call here
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(success);
            } else {
                alert("Geolocation not supported!");
            }
        });

        let markers = []; //google place results' markers array
        var highestRatingMarker = [];
        var mostRatedMarker = [];
        var nearestMarker = [];
        let map;
        let service;
        let infowindow;
        let lat, long, LatLng;
        let searchedResults = [];
        const googleMapLink = "https://www.google.com/maps/dir/";
        const image = "https://developers.google.com/maps/documentation/javascript/examples/full/images/beachflag.png";

        function success(position) {

            //GOOGLE_MAP--------
            var name = getParameterByName('name');
            lat = position.coords.latitude;
            long = position.coords.longitude;
            LatLng = new google.maps.LatLng(lat, long);
            

            //https://www.google.com/maps/dir/2.8000601238492435,%2B101.49562181470077/hospital%20banting
            //GOOGLE_MAP PROPERTIES
            map = new google.maps.Map(document.getElementById("googleMap"),{
                center: LatLng,
                zoom: 14,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            });

            //INITIAL PROPERTIES
            var initMarker = new google.maps.Marker({
                position: LatLng,
                animation: google.maps.Animation.DROP,
                title: "<div style = 'height:60px;width:200px'><b>Your location:</b><br />Latitude: "
                    + lat +"<br />Longitude: " + long
            });
            initMarker.setMap(map);
            var getInfoWindow = new google.maps.InfoWindow({
                content: "<b>Your Current Location</b><br/> Latitude:" +
                    lat + "<br /> Longitude:" + long + "<br/><a href=\"" 
            });

            //getInfoWindow.open(map, initMarker);
            //click to open info window
            initMarker.addListener("click", () => {
                getInfoWindow.open(map, initMarker);
            });


            //AUTO_COMPLETE------------------------------
            document.getElementById('autoComplete').innerHTML = "Search a location using the search bar above the google map.";

            autocomplete = new google.maps.places.Autocomplete(document.getElementById("input"), {
                fields: ['geometry', 'name', 'rating', 'formatted_address'],
                componentRestrictions: { 'country': ['MY'] },
                types:['establishment']
            });

            autocomplete.addListener("place_changed", () => {
                const place = autocomplete.getPlace();
                var searchedLink = googleMapLink + lat + "," + long + "/" + place.geometry.location;
                var searchedMarker = new google.maps.Marker({
                    position: place.geometry.location,
                    title: place.name,
                    icon: image,
                    map: map,
                    animation: google.maps.Animation.DROP,
                });

                placeLink = googleMapLink + lat + "," + long + "/" + place.geometry.location;

                document.getElementById('autoComplete').innerHTML = (`${place.name} is the searched location with a rating of ${place.rating} on google. <br/><br/>
                                                                Location Address : ${place.formatted_address}<br/>
                                                                <a href="${placeLink}" class="navigateButton">Navigate Now</a>`);
                //var d = distance(LatLng, place.geometry.location);
                
                //alert(d);
                

                searchedMarker.setMap(map);
                

                var getDestinationInfoWindow = new google.maps.InfoWindow({

                    content: "<b>Searched Place <br><hr><br>" + place.name + "</b><br>" + place.geometry.location + "<br/><br/><a href=\"" + searchedLink + "\" style=\"font-size:large;text-decoration:none\">Navigate</a><br/>" 
                });

                //click to open info window
                searchedMarker.addListener("click", () => {
                    getDestinationInfoWindow.open(map, searchedMarker);
                });
            });


            //GOOGLE_PLACE SEARCH
            if (name != null) {
                showAutoSearch();
                var request = {
                    location: LatLng,
                    radius: 500,
                    query: name,
                    //fields: ["name", "geometry"],
                    //types: ["point_of_interest", "establishment"]
                    //openNow: true;
                };
                
                service = new google.maps.places.PlacesService(map);

                service.textSearch(request, callback);
            } else {
                hideAutoSearch();
                hideSlider();
                document.getElementById('demo').innerHTML = "No location found...";
            }

        }

        function hideSlider() {
            var x = document.getElementsByClassName('main');
            x[0].style.display = 'none';
        }

        function showSlider() {
            var x = document.getElementsByClassName('main');
            x[0].style.display = 'block';
        }

        //radio button and the content
        function hideAutoSearch() {
            var x = document.getElementsByClassName('searchedResults');
            x[0].style.display = 'none';
          
        }

        function showAutoSearch() {
            var x = document.getElementsByClassName('searchedResults');
            x[0].style.display = 'block';

        }

        function callback(results, status) {
            if (status == google.maps.places.PlacesServiceStatus.OK) {
                
                for (var i = 0; i < results.length; i++) {
                    createMarker(results[i], markers);
                    //console.log(results[i]);
                }
                searchedResults = results;//save the result for further use
                suggestedResult(); //create marker and write result
            } 
        }

        function getNearestLocation() {
            hideSlider();
            //nearest location 
            
            var nearestDistance = distance(LatLng, searchedResults[0].geometry.location);
            var newNearestDistance;
            var nearestLocation = searchedResults[0];
            
            //console.log(searchedResults[0].name +  " >> initial distance :" + nearestDistance);

            for (var i = 1; i < searchedResults.length; i++) {

                newNearestDistance = distance(LatLng, searchedResults[i].geometry.location);
                //console.log(searchedResults[i].name + " >>  distance :" + newNearestDistance);

                if (newNearestDistance < nearestDistance ) {
                    nearestLocation = searchedResults[i];
                    nearestDistance = newNearestDistance;
                }

            }

            if (nearestMarker.length == 0) {
                createMarker(nearestLocation, nearestMarker);
            }

            showMarkers(nearestMarker);

            return [nearestLocation , nearestDistance];
        }

        function getHighestRatingLocation() {
            //highest rating
            showSlider();
            var highestRatingLocation;
            var isFirstTime = true;

            for (var i = 0; i < searchedResults.length; i++) {

                var d = distance(LatLng, searchedResults[i].geometry.location);
                if (d <= radius) { //limit the highest rating location

                    if (isFirstTime) {
                        highestRatingLocation = searchedResults[i];
                        isFirstTime = false;
                    }

                    if (highestRatingLocation.rating < searchedResults[i].rating) {
                        highestRatingLocation = searchedResults[i];

                    }
                }
            }

            return highestRatingLocation;
        }

        function getMostRatedLocation() {
            //most rated 
            showSlider();
            var mostRatedLocation;
            var isFirstTime = true;

            for (var i = 0; i < searchedResults.length; i++) {

                var d = distance(LatLng, searchedResults[i].geometry.location);
                if (d <= radius) { //limit the highest rating location

                    if (isFirstTime) {
                        mostRatedLocation = searchedResults[i];
                        isFirstTime = false;
                    }

                    if (mostRatedLocation.user_ratings_total < searchedResults[i].user_ratings_total) {
                        mostRatedLocation = searchedResults[i];

                    }
                }
            }

            return mostRatedLocation;
        }

        //need to have the results
        function suggestedResult() {

            //NEAREST=======================================
            if (document.getElementById('nearest').checked) {

                clearMarkers(highestRatingMarker);
                clearMarkers(markers);
                clearMarkers(mostRatedMarker);

                var nearestLocationLink;

                //get nearest location
                var nearestValues = getNearestLocation();

                var nearestLocation = nearestValues[0];
                var nearestDistance = nearestValues[1];

                if (nearestLocation != null) {

                    nearestLocationLink = googleMapLink + lat + "," + long + "/" + nearestLocation.geometry.location;

                    document.getElementById("demo").innerHTML = (`${nearestLocation.name} is the nearest location around you 
                                                                    with distance of ${nearestDistance.toFixed(2)} meters and a rating of <b> ${nearestLocation.rating}</b> on google. <br/><br/>
                                                                Location Address : ${nearestLocation.formatted_address}<br/>
                                                                <a href="${nearestLocationLink}" class="navigateButton">Navigate Now</a>`);
                }

                //HIGHEST RATING=======================================
            } else if (document.getElementById('highestRating').checked) {

                clearMarkers(markers);//clear all google place searched markers
                clearMarkers(nearestMarker);
                clearMarkers(mostRatedMarker);

                var highestRatingLink = googleMapLink;

                var highestRatingLocation = getHighestRatingLocation();

                if (highestRatingLocation != null) {

                    highestRatingLink = googleMapLink + lat + "," + long + "/" + highestRatingLocation.geometry.location;

                    document.getElementById("demo").innerHTML = (`${highestRatingLocation.name} is the highest rated location in ${radius}m
                                                                    with a rating of <b> ${highestRatingLocation.rating}</b> on google. <br/><br/>
                                                                Location Address : ${highestRatingLocation.formatted_address}<br/>
                                                                <a href="${highestRatingLink}" class="navigateButton">Navigate Now</a>`);

                    deleteMarkers(highestRatingMarker);
                    createMarker(highestRatingLocation, highestRatingMarker);
                    //console.log(highestRatingLocation.user_ratings_total);

                } else {
                    deleteMarkers(highestRatingMarker);
                    document.getElementById("demo").innerHTML = (`No location found...`);
                }

                showMarkers(highestRatingMarker);

                //MOST RATED=======================================
            } else if (document.getElementById('mostRated').checked) {

                clearMarkers(markers);//clear all google place searched markers
                clearMarkers(nearestMarker);
                clearMarkers(highestRatingMarker);

                var mostRatedLink = googleMapLink;

                var mostRatedLocation = getMostRatedLocation();

                if (mostRatedLocation != null) {

                    mostRatedLink = googleMapLink + lat + "," + long + "/" + mostRatedLocation.geometry.location;

                    document.getElementById("demo").innerHTML = (`With ${mostRatedLocation.user_ratings_total} ratings, ${mostRatedLocation.name} is the most rated location in ${radius}m.
                                                                    with a rating of <b> ${mostRatedLocation.rating}</b> on google. <br/><br/>
                                                                Location Address : ${mostRatedLocation.formatted_address}<br/>
                                                                <a href="${mostRatedLink}" class="navigateButton">Navigate Now</a>`);

                    deleteMarkers(mostRatedMarker);
                    createMarker(mostRatedLocation, mostRatedMarker);
                    //console.log(highestRatingLocation.user_ratings_total);

                } else {
                    deleteMarkers(mostRatedMarker);
                    document.getElementById("demo").innerHTML = (`No location found...`);
                }

                showMarkers(mostRatedMarker);

                //RECOMMENDED=======================================
            } else if (document.getElementById('recommended').checked) {

                var recommendedLocation; var m_allLocationAverage; var totalRatings = 0;
                var ratingList = []; var C_lowerQuartile;var limitRange = 10000;var count = 0;
                var isFirstTime = true; var highestBayesianRating; var newHighestBayesianRating;

                //recommended location considering three factors 
                var mostRatedLocation = getMostRatedLocation();
                var highestRatingLocation = getHighestRatingLocation();
                var nearestValues = getNearestLocation();
                var nearestLocation = nearestValues[0];
                var nearestDistance = nearestValues[1];

                if (mostRatedLocation == highestRatingLocation && highestRatingLocation == nearestLocation) {
                    // if three location are the same means the best location
                    recommendedLocation = highestRatingLocation;
                    console.log("best location = ");
                    console.log(recommendedLocation);

                } else {

                    for (var i = 0; i < searchedResults.length; i++) {

                        var d = distance(LatLng, searchedResults[i].geometry.location);
                        
                        if (d < limitRange) {
                            totalRatings += searchedResults[i].rating;
                            ratingList.push(searchedResults[i].user_ratings_total);
                            count++;
                            //console.log(searchedResults[i]);
                        }
                    }

                    m_allLocationAverage = totalRatings / count;
                    C_lowerQuartile = mean(ratingList);
                    
                    /*C_lowerQuartile = Quartile(ratingList, 0.25);

                    if (C_lowerQuartile == 0) {
                        
                    }*/

                    console.log(`m = ${m_allLocationAverage} and c = ${C_lowerQuartile} count= ${count} total rating = ${totalRatings}`);
                    
                    for (var i = 0; i < searchedResults.length; i++) {
                        var d = distance(LatLng, searchedResults[i].geometry.location);

                        if (d < limitRange) {
                            if (isFirstTime) {
                                recommendedLocation = searchedResults[i];
                                highestBayesianRating = calculateBayesAverage(searchedResults[i].user_ratings_total
                                    , searchedResults[i].rating, m_allLocationAverage, C_lowerQuartile);
                                console.log("first = " + highestBayesianRating);
                                isFirstTime = false;
                            }

                            newHighestBayesianRating = calculateBayesAverage(searchedResults[i].user_ratings_total
                                , searchedResults[i].rating, m_allLocationAverage, C_lowerQuartile);

                            console.log("new= "+newHighestBayesianRating);
                            console.log(searchedResults[i]);

                            if (newHighestBayesianRating > highestBayesianRating) {
                                highestBayesianRating = newHighestBayesianRating;
                                recommendedLocation = searchedResults[i];
                            }
                            
                        }
                    } console.log("Highest = "+highestBayesianRating);
                    /*
                    for (var i = 0; i < searchedResults.length; i++) {
                        if (C_lowerQuartile == 0) {
                            C_lowerQuartile = 2;
                        }

                        newHighestBayesianRating = calculateBayesAverage(searchedResults[i].user_ratings_total
                            , searchedResults[i].rating, m_allLocationAverage, C_lowerQuartile);
                        console.log(i + 1 + "Rating = " + newHighestBayesianRating);
                        console.log(searchedResults[i]);
                    }*/

                }
                

            } else {

                //show all
                hideSlider();
                //create marker
                clearMarkers(highestRatingMarker);
                clearMarkers(nearestMarker);
                clearMarkers(mostRatedMarker);
                showMarkers(markers);
               

                if (searchedResults.length != 0) {
                    document.getElementById('demo').innerHTML = (`<b>Click on the marker to see detailed informations.</b><br/><br/>
                                                              Click the navigation link to proceed to navigate in google map.
                                                               You are able to click the link in the google map to send location
                                                               to your smartphone and proceed to your destination. <br/><br/>
                                                               Have a nice day~~~`);
                }
            }

        }
                                        //user_rating_total      //rating
        function calculateBayesAverage(product_ratings_count, product_ratings_average, m_allLocationAverage, C_lowerQuartile) {
            if (product_ratings_count == 0) {
                return 0;
            } else {
                return (product_ratings_count * product_ratings_average + m_allLocationAverage * C_lowerQuartile)
                    / (product_ratings_count + C_lowerQuartile)
            }            
        }

        function mean(numbers) {
            var total = 0, i;
            for (i = 0; i < numbers.length; i += 1) {
                total += numbers[i];
            }
            return total / numbers.length;
        }

        //sort array
        function Array_Sort_Numbers(inputarray) {
            return inputarray.sort(function (a, b) {
                return a - b;
            });
        }

        //get rating quartile
        function Quartile(data, q) {
            data = Array_Sort_Numbers(data);
            var pos = ((data.length) - 1) * q;
            var base = Math.floor(pos);
            var rest = pos - base;
            if ((data[base + 1] !== undefined)) {
                return data[base] + rest * (data[base + 1] - data[base]);
            } else {
                return data[base];
            }
        }

        // marker functions
        // Sets the map on all markers in the array.
        function setMapOnAll(map , array) {
            for (let i = 0; i < array.length; i++) {
                array[i].setMap(map);
            }
        }

        // Removes the markers from the map, but keeps them in the array.
        function clearMarkers(array) {
            setMapOnAll(null,array);
        }

        // Shows any markers currently in the array.
        function showMarkers(array) {
            setMapOnAll(map,array);
        }

        // Deletes all markers in the array by removing references to them.
        function deleteMarkers(array) {
            clearMarkers(array);
            array.length = 0;
        }

        //Returns Distance between two latlng objects using haversine formula
        function distance(p1, p2) {
            if (!p1 || !p2)
                return 0;
            var R = 6371000; // Radius of the Earth in m
            var dLat = (p2.lat() - p1.lat()) * Math.PI / 180;
            var dLon = (p2.lng() - p1.lng()) * Math.PI / 180;
            var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(p1.lat() * Math.PI / 180) * Math.cos(p2.lat() * Math.PI / 180) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2);
            var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            var d = R * c;
            return d;
        }

        function createMarker(place, array) {

            if (!place.geometry || !place.geometry.location) {
                return;
            }
            var link = googleMapLink + lat + "," + long + "/" + place.geometry.location;

            const marker = new google.maps.Marker({
                map,
                position: place.geometry.location,
                icon: image,
            });

            var placeInfoWindow = new google.maps.InfoWindow({
                content: "<b>Searched Place <br><hr><br>" + place.name + "</b><br>" + place.geometry.location + "<br><br/><a href=\"" + link + "\" style=\"font-size:large;text-decoration:none\">Navigate</a><br/>" 
            });

            google.maps.event.addListener(marker, "click", () => {
                placeInfoWindow.open(map, marker);
            });

            array.push(marker);
        }

        //RETRIEVE QUERY STRING FUNCTION
        function getParameterByName(name, url = window.location.href) {
            name = name.replace(/[\[\]]/g, '\\$&');
            var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
                results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, ' '));
        }



    </script>  


<!--<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCOs73MjrEETY_b9lbU9QCco5DoMll2UOY&callback=myMap"></script>-->

</asp:Content>
